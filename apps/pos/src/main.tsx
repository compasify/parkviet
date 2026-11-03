import React, { useState } from 'react'
import { createRoot } from 'react-dom/client'
import i18n from 'i18next'
import { initReactI18next, useTranslation } from 'react-i18next'
import { createSession } from './session'
import './styles.css'

void i18n.use(initReactI18next).init({
  lng: 'vi', fallbackLng: 'vi', interpolation: { escapeValue: false },
  resources: { vi: { translation: {
    badge: 'BẢN ĐANG PHÁT TRIỂN', title: 'Không gian bán hàng',
    intro: 'Đăng nhập bằng tài khoản nhân viên Spree để bắt đầu.', email: 'Email nhân viên',
    password: 'Mật khẩu', login: 'Đăng nhập', waiting: 'Đang xử lý…', logout: 'Đăng xuất',
    failure: 'Không thể đăng nhập hoặc tải thông tin nhân viên. Kiểm tra tài khoản và kết nối rồi thử lại.',
    logoutFailure: 'Đã khóa phiên trên màn hình này, nhưng chưa xác nhận thu hồi phiên trên máy chủ. Hãy kiểm tra kết nối và thu hồi phiên qua quản trị.',
    hello: 'Xin chào, {{name}}', placeholder: 'Khu vực bán hàng đang được xây dựng.',
    notice: 'Chưa thể tạo đơn, kiểm tra tồn kho hoặc thu tiền tại đây.',
    branch: 'Cửa hàng và quầy chưa được kết nối', security: 'Phiên chỉ lưu trong bộ nhớ trình duyệt.',
  } } },
})

const session = createSession()

function App() {
  const { t } = useTranslation()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [name, setName] = useState('')
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')

  async function login(event: React.FormEvent) {
    event.preventDefault()
    setBusy(true); setError('')
    try {
      const result = await session.login(email, password)
      setName(result.user.full_name || result.user.email)
      setPassword('')
    } catch {
      setPassword('')
      setError(t('failure'))
    } finally { setBusy(false) }
  }

  async function logout() {
    setBusy(true); setError(''); setName('')
    try { await session.logout() } catch { setError(t('logoutFailure')) }
    finally { setBusy(false) }
  }

  return <main className="layout">
    <header className="header"><strong>ParkViet <span>POS</span></strong><small>{t('badge')}</small></header>
    <section className="panel" aria-labelledby="title">
      <div className="eyebrow">PARKVIET / POS</div>
      <h1 id="title">{name ? t('hello', { name }) : t('title')}</h1>
      {error && <p className="error" role="alert">{error}</p>}
      {name ? <>
        <p>{t('branch')}</p><div className="empty"><strong>{t('placeholder')}</strong><p>{t('notice')}</p></div>
        <button type="button" onClick={logout} disabled={busy}>{busy ? t('waiting') : t('logout')}</button>
      </> : <>
        <p>{t('intro')}</p>
        <form onSubmit={login}>
          <label htmlFor="email">{t('email')}</label>
          <input id="email" type="email" autoComplete="username" value={email} onChange={e => setEmail(e.target.value)} required />
          <label htmlFor="password">{t('password')}</label>
          <input id="password" type="password" autoComplete="current-password" value={password} onChange={e => setPassword(e.target.value)} required />
          <button disabled={busy}>{busy ? t('waiting') : t('login')}</button>
        </form>
      </>}
      <p className="footnote">{t('security')}</p>
    </section>
  </main>
}

createRoot(document.getElementById('root')!).render(<React.StrictMode><App /></React.StrictMode>)
