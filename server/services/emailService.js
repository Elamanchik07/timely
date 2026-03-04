const nodemailer = require('nodemailer');

class EmailService {
  constructor() {
    this.transporter = null;
    this._initialized = false;
    this._initPromise = this._init();
  }

  async _init() {
    const provider = (process.env.EMAIL_PROVIDER || '').toLowerCase();
    const isDev = process.env.NODE_ENV === 'development';

    // Transport selection rules:
    // If NODE_ENV=production OR EMAIL_PROVIDER is set to gmail/smtp/sendgrid -> use real provider
    // Use Ethereal ONLY if: NODE_ENV=development AND EMAIL_PROVIDER=ethereal

    if (provider === 'ethereal' && isDev) {
      try {
        const testAccount = await nodemailer.createTestAccount();
        this.transporter = nodemailer.createTransport({
          host: 'smtp.ethereal.email',
          port: 587,
          secure: false,
          auth: {
            user: testAccount.user,
            pass: testAccount.pass
          }
        });

        // Let's store ethereal property for the logging of preview URLs
        this.transporter.isEthereal = true;

        console.log('✉️  Email service: using Ethereal test account (DEV ONLY)');
        console.log('    → Ethereal user:', testAccount.user);
      } catch (e) {
        console.warn('⚠️  Could not create Ethereal account, email disabled:', e.message);
        this.transporter = null;
      }
    } else if (process.env.NODE_ENV === 'production' || ['gmail', 'smtp', 'sendgrid'].includes(provider)) {
      // Use Real Provider configuration
      let host = process.env.EMAIL_HOST || 'smtp.gmail.com';
      let port = parseInt(process.env.EMAIL_PORT) || 587;
      let secure = process.env.EMAIL_SECURE === 'true' || port === 465;

      this.transporter = nodemailer.createTransport({
        host: host,
        port: port,
        secure: secure,
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS
        },
        tls: {
          rejectUnauthorized: false
        }
      });

      this.transporter.isEthereal = false;
      this.transporter.providerName = provider || 'smtp/gmail';
      console.log(`✉️  Email service: using ${this.transporter.providerName} SMTP (${host}:${port})`);
    } else {
      console.warn('⚠️  Email service: no valid credentials/provider configured. Emails disabled.');
      this.transporter = null;
    }

    this._initialized = true;
  }

  async _ensureReady() {
    if (!this._initialized) {
      await this._initPromise;
    }
  }

  async _sendMail(mailOptions, logLabel) {
    await this._ensureReady();

    if (!this.transporter) {
      console.log(`📧 [${logLabel}] EMAIL NOT SENT (no transporter). Details:`);
      console.log(`   To: ${mailOptions.to}`);
      console.log(`   Subject: ${mailOptions.subject}`);
      return { success: false, error: 'NO_TRANSPORTER' };
    }

    try {
      const info = await this.transporter.sendMail(mailOptions);

      const providerStr = this.transporter.isEthereal ? 'ethereal' : this.transporter.providerName;
      const hostStr = this.transporter.options.host;
      const portStr = this.transporter.options.port;

      console.log(`✉️  [${logLabel}] sent to ${mailOptions.to}`);
      console.log(`   Provider: ${providerStr} | Host: ${hostStr}:${portStr}`);
      console.log(`   MessageID: ${info.messageId}`);

      // If using Ethereal, show preview URL
      if (this.transporter.isEthereal) {
        const previewUrl = nodemailer.getTestMessageUrl(info);
        if (previewUrl) {
          console.log(`   → Preview URL: ${previewUrl}`);
        }
      }

      return { success: true, messageId: info.messageId, response: info.response, info: info };
    } catch (error) {
      console.error(`❌ [${logLabel}] Nodemailer error:`, error.message);
      return { success: false, error: error.message };
    }
  }

  async sendRegistrationEmail(userEmail, fullName) {
    return this._sendMail({
      from: `"Timely App" <${process.env.EMAIL_USER || 'noreply@timely.app'}>`,
      to: userEmail,
      subject: 'Заявка на доступ принята - Timely',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #2196F3;">Добро пожаловать в Timely!</h2>
          <p>Здравствуйте, ${fullName}!</p>
          <p>Ваша заявка на доступ к приложению Timely успешно принята.</p>
          <p><strong>Статус:</strong> Ожидает одобрения администратора</p>
          <p>Вы получите уведомление по электронной почте, как только администратор одобрит вашу заявку.</p>
          <hr style="border: 1px solid #e0e0e0; margin: 20px 0;">
          <p style="color: #666; font-size: 12px;">Это автоматическое письмо. Пожалуйста, не отвечайте на него.</p>
        </div>
      `
    }, 'REGISTRATION');
  }

  async sendApprovalEmail(userEmail, fullName) {
    return this._sendMail({
      from: `"Timely App" <${process.env.EMAIL_USER || 'noreply@timely.app'}>`,
      to: userEmail,
      subject: 'Ваш аккаунт одобрен! - Timely',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #4CAF50;">Ваш аккаунт одобрен!</h2>
          <p>Здравствуйте, ${fullName}!</p>
          <p>Отличные новости! Администратор одобрил вашу заявку.</p>
          <p><strong>Статус:</strong> Одобрен ✅</p>
          <p>Теперь вы можете войти в приложение Timely.</p>
          <hr style="border: 1px solid #e0e0e0; margin: 20px 0;">
          <p style="color: #666; font-size: 12px;">Это автоматическое письмо. Пожалуйста, не отвечайте на него.</p>
        </div>
      `
    }, 'APPROVAL');
  }

  async sendRejectionEmail(userEmail, fullName) {
    return this._sendMail({
      from: `"Timely App" <${process.env.EMAIL_USER || 'noreply@timely.app'}>`,
      to: userEmail,
      subject: 'Заявка отклонена - Timely',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #F44336;">Заявка отклонена</h2>
          <p>Здравствуйте, ${fullName}!</p>
          <p>К сожалению, ваша заявка на доступ к приложению Timely была отклонена.</p>
          <p><strong>Статус:</strong> Отклонён ❌</p>
          <p>Если у вас есть вопросы, свяжитесь с администратором.</p>
          <hr style="border: 1px solid #e0e0e0; margin: 20px 0;">
          <p style="color: #666; font-size: 12px;">Это автоматическое письмо. Пожалуйста, не отвечайте на него.</p>
        </div>
      `
    }, 'REJECTION');
  }

  async sendPasswordResetCode(userEmail, fullName, code) {
    // ALWAYS log the code in dev mode for testing
    if (process.env.NODE_ENV !== 'production') {
      console.log('');
      console.log('╔══════════════════════════════════════╗');
      console.log('║    🔑 PASSWORD RESET CODE            ║');
      console.log(`║    User:  ${userEmail.padEnd(26)}║`);
      console.log(`║    Code:  ${String(code).padEnd(26)}║`);
      console.log('╚══════════════════════════════════════╝');
      console.log('');
    }

    return this._sendMail({
      from: `"Timely App" <${process.env.EMAIL_USER || 'noreply@timely.app'}>`,
      to: userEmail,
      subject: 'Код сброса пароля - Timely',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #3A86FF;">Сброс пароля</h2>
          <p>Здравствуйте, ${fullName}!</p>
          <p>Вы запросили сброс пароля для вашего аккаунта Timely.</p>
          <p>Ваш код подтверждения:</p>
          <div style="text-align: center; margin: 30px 0;">
            <div style="display: inline-block; background-color: #f5f5f5; border: 2px solid #3A86FF; border-radius: 12px; padding: 20px 40px;">
              <span style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #3A86FF;">${code}</span>
            </div>
          </div>
          <p><strong>⏱ Код действителен 10 минут.</strong></p>
          <p style="color: #666;">Если вы не запрашивали сброс пароля, проигнорируйте это письмо.</p>
          <hr style="border: 1px solid #e0e0e0; margin: 20px 0;">
          <p style="color: #666; font-size: 12px;">Это автоматическое письмо. Пожалуйста, не отвечайте на него.</p>
        </div>
      `
    }, 'PASSWORD_RESET');
  }
}

module.exports = new EmailService();
