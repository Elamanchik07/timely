const nodemailer = require('nodemailer');

class EmailService {
  constructor() {
    this.transporter = null;
    this._initialized = false;
    this._useResend = false;
    this._resendApiKey = null;
    this._useBrevo = false;
    this._brevoApiKey = null;
    this._initPromise = this._init();
  }

  async _init() {
    // Priority 1: Brevo HTTP API (free 300/day, no domain verification needed)
    if (process.env.BREVO_API_KEY) {
      this._useBrevo = true;
      this._brevoApiKey = process.env.BREVO_API_KEY;
      console.log('✉️  Email service: using Brevo HTTP API');
      this._initialized = true;
      return;
    }

    // Priority 2: Resend HTTP API
    if (process.env.RESEND_API_KEY) {
      this._useResend = true;
      this._resendApiKey = process.env.RESEND_API_KEY;
      console.log('✉️  Email service: using Resend HTTP API');
      this._initialized = true;
      return;
    }

    const provider = (process.env.EMAIL_PROVIDER || '').toLowerCase();
    const isDev = process.env.NODE_ENV === 'development';

    if (provider === 'ethereal' && isDev) {
      try {
        const testAccount = await nodemailer.createTestAccount();
        this.transporter = nodemailer.createTransport({
          host: 'smtp.ethereal.email',
          port: 587,
          secure: false,
          auth: { user: testAccount.user, pass: testAccount.pass }
        });
        this.transporter.isEthereal = true;
        console.log('✉️  Email service: using Ethereal test account (DEV ONLY)');
      } catch (e) {
        console.warn('⚠️  Could not create Ethereal account, email disabled:', e.message);
        this.transporter = null;
      }
    } else if (process.env.NODE_ENV === 'production' || ['gmail', 'smtp', 'sendgrid'].includes(provider)) {
      let host = process.env.EMAIL_HOST || 'smtp.gmail.com';
      let port = parseInt(process.env.EMAIL_PORT) || 587;
      let secure = process.env.EMAIL_SECURE === 'true' || port === 465;

      this.transporter = nodemailer.createTransport({
        host, port, secure,
        auth: { user: process.env.EMAIL_USER, pass: process.env.EMAIL_PASS },
        tls: { rejectUnauthorized: false },
        connectionTimeout: 5000,
        socketTimeout: 5000,
        greetingTimeout: 5000
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
    if (!this._initialized) await this._initPromise;
  }

  // Send via Brevo (Sendinblue) HTTP API - free 300/day, no domain verification
  async _sendViaBrevo(mailOptions, logLabel) {
    try {
      const senderEmail = process.env.EMAIL_USER || 'noreply@timely.app';
      const senderName = 'Timely App';
      const response = await fetch('https://api.brevo.com/v3/smtp/email', {
        method: 'POST',
        headers: {
          'api-key': this._brevoApiKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          sender: { name: senderName, email: senderEmail },
          to: [{ email: mailOptions.to }],
          subject: mailOptions.subject,
          htmlContent: mailOptions.html
        })
      });

      const data = await response.json();

      if (response.ok) {
        console.log(`✉️  [${logLabel}] sent via Brevo to ${mailOptions.to}, ID: ${data.messageId}`);
        return { success: true, messageId: data.messageId };
      } else {
        console.error(`❌ [${logLabel}] Brevo error:`, data);
        return { success: false, error: data.message || JSON.stringify(data) };
      }
    } catch (error) {
      console.error(`❌ [${logLabel}] Brevo fetch error:`, error.message);
      return { success: false, error: error.message };
    }
  }

  // Send via Resend HTTP API (works on Railway, no SMTP ports needed)
  async _sendViaResend(mailOptions, logLabel) {
    try {
      const fromEmail = process.env.RESEND_FROM || 'Timely <onboarding@resend.dev>';
      const response = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this._resendApiKey}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          from: fromEmail,
          to: [mailOptions.to],
          subject: mailOptions.subject,
          html: mailOptions.html
        })
      });

      const data = await response.json();

      if (response.ok) {
        console.log(`✉️  [${logLabel}] sent via Resend to ${mailOptions.to}, ID: ${data.id}`);
        return { success: true, messageId: data.id };
      } else {
        console.error(`❌ [${logLabel}] Resend error:`, data);
        return { success: false, error: data.message || JSON.stringify(data) };
      }
    } catch (error) {
      console.error(`❌ [${logLabel}] Resend fetch error:`, error.message);
      return { success: false, error: error.message };
    }
  }

  async _sendMail(mailOptions, logLabel) {
    await this._ensureReady();

    // Use Brevo if configured
    if (this._useBrevo) {
      return this._sendViaBrevo(mailOptions, logLabel);
    }

    // Use Resend if configured
    if (this._useResend) {
      return this._sendViaResend(mailOptions, logLabel);
    }

    if (!this.transporter) {
      console.log(`📧 [${logLabel}] EMAIL NOT SENT (no transporter). To: ${mailOptions.to}`);
      return { success: false, error: 'NO_TRANSPORTER' };
    }

    try {
      const info = await this.transporter.sendMail(mailOptions);
      const providerStr = this.transporter.isEthereal ? 'ethereal' : this.transporter.providerName;
      console.log(`✉️  [${logLabel}] sent to ${mailOptions.to} via ${providerStr}, MsgID: ${info.messageId}`);

      if (this.transporter.isEthereal) {
        const previewUrl = nodemailer.getTestMessageUrl(info);
        if (previewUrl) console.log(`   → Preview URL: ${previewUrl}`);
      }

      return { success: true, messageId: info.messageId, response: info.response, info };
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
      html: `<div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto"><h2 style="color:#2196F3">Добро пожаловать в Timely!</h2><p>Здравствуйте, ${fullName}!</p><p>Ваша заявка на доступ к приложению Timely успешно принята.</p><p><strong>Статус:</strong> Ожидает одобрения администратора</p><p>Вы получите уведомление, как только администратор одобрит вашу заявку.</p><hr style="border:1px solid #e0e0e0;margin:20px 0"><p style="color:#666;font-size:12px">Это автоматическое письмо.</p></div>`
    }, 'REGISTRATION');
  }

  async sendApprovalEmail(userEmail, fullName) {
    return this._sendMail({
      from: `"Timely App" <${process.env.EMAIL_USER || 'noreply@timely.app'}>`,
      to: userEmail,
      subject: 'Ваш аккаунт одобрен! - Timely',
      html: `<div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto"><h2 style="color:#4CAF50">Ваш аккаунт одобрен!</h2><p>Здравствуйте, ${fullName}!</p><p>Администратор одобрил вашу заявку.</p><p><strong>Статус:</strong> Одобрен ✅</p><p>Теперь вы можете войти в приложение Timely.</p><hr style="border:1px solid #e0e0e0;margin:20px 0"><p style="color:#666;font-size:12px">Это автоматическое письмо.</p></div>`
    }, 'APPROVAL');
  }

  async sendRejectionEmail(userEmail, fullName) {
    return this._sendMail({
      from: `"Timely App" <${process.env.EMAIL_USER || 'noreply@timely.app'}>`,
      to: userEmail,
      subject: 'Заявка отклонена - Timely',
      html: `<div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto"><h2 style="color:#F44336">Заявка отклонена</h2><p>Здравствуйте, ${fullName}!</p><p>К сожалению, ваша заявка была отклонена.</p><p><strong>Статус:</strong> Отклонён ❌</p><hr style="border:1px solid #e0e0e0;margin:20px 0"><p style="color:#666;font-size:12px">Это автоматическое письмо.</p></div>`
    }, 'REJECTION');
  }

  async sendPasswordResetCode(userEmail, fullName, code) {
    console.log('');
    console.log('╔══════════════════════════════════════╗');
    console.log('║    🔑 PASSWORD RESET CODE            ║');
    console.log(`║    User:  ${userEmail.padEnd(26)}║`);
    console.log(`║    Code:  ${String(code).padEnd(26)}║`);
    console.log('╚══════════════════════════════════════╝');
    console.log('');

    return this._sendMail({
      from: `"Timely App" <${process.env.EMAIL_USER || 'noreply@timely.app'}>`,
      to: userEmail,
      subject: 'Код сброса пароля - Timely',
      html: `<div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto"><h2 style="color:#3A86FF">Сброс пароля</h2><p>Здравствуйте, ${fullName}!</p><p>Вы запросили сброс пароля для вашего аккаунта Timely.</p><p>Ваш код подтверждения:</p><div style="text-align:center;margin:30px 0"><div style="display:inline-block;background:#f5f5f5;border:2px solid #3A86FF;border-radius:12px;padding:20px 40px"><span style="font-size:36px;font-weight:bold;letter-spacing:8px;color:#3A86FF">${code}</span></div></div><p><strong>⏱ Код действителен 10 минут.</strong></p><p style="color:#666">Если вы не запрашивали сброс пароля, проигнорируйте это письмо.</p><hr style="border:1px solid #e0e0e0;margin:20px 0"><p style="color:#666;font-size:12px">Это автоматическое письмо.</p></div>`
    }, 'PASSWORD_RESET');
  }
}

module.exports = new EmailService();
