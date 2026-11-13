import sharedEn from '@parkviet/pos-shared/locales/en'
import sharedVi from '@parkviet/pos-shared/locales/vi'
import { i18n } from '@spree/dashboard-core'
import en from './locales/en.json'
import vi from './locales/vi.json'

const shell = {
  en: {
    posDashboard: {
      title: 'POS administration',
      signIn: 'Sign in',
      email: 'Email',
      password: 'Password',
      forgotPassword: 'Forgot password?',
      resetPassword: 'Send reset instructions',
      resetSent: 'If this account exists, password reset instructions have been sent.',
      backToLogin: 'Back to sign in',
      noStore: 'You do not have access to a store.',
      signOut: 'Sign out',
      settings: 'Settings',
      overview: 'Overview',
      forbidden: 'You do not have permission to view this page.',
      notFound: 'Page not found',
      error: 'Something went wrong. Please try again.',
      branch: 'Branch',
      noBranches: 'No available branches',
      openCounter: 'POS',
    },
  },
  vi: {
    posDashboard: {
      title: 'Quản trị POS',
      signIn: 'Đăng nhập',
      email: 'Email',
      password: 'Mật khẩu',
      forgotPassword: 'Quên mật khẩu?',
      resetPassword: 'Gửi hướng dẫn đặt lại mật khẩu',
      resetSent: 'Nếu tài khoản tồn tại, hướng dẫn đặt lại mật khẩu đã được gửi.',
      backToLogin: 'Quay lại đăng nhập',
      noStore: 'Bạn chưa được cấp quyền truy cập cửa hàng.',
      signOut: 'Đăng xuất',
      settings: 'Cài đặt',
      overview: 'Tổng quan',
      forbidden: 'Bạn không có quyền xem trang này.',
      notFound: 'Không tìm thấy trang',
      error: 'Đã xảy ra lỗi. Vui lòng thử lại.',
      branch: 'Chi nhánh',
      noBranches: 'Chưa có chi nhánh',
      openCounter: 'POS',
    },
  },
}
const shared = { en: sharedEn, vi: sharedVi }
// The texts of the shared POS logic (receipts, refusals, modules, profiles)
// join the app's own in both namespaces; deep merge keeps sections both fill.
for (const [code, bundle] of Object.entries({ en, vi })) {
  for (const ns of ['translation', 'pos']) {
    i18n.addResourceBundle(code, ns, shared[code as 'en' | 'vi'], true, true)
    i18n.addResourceBundle(code, ns, bundle, true, true)
  }
  i18n.addResourceBundle(code, 'translation', shell[code as 'en' | 'vi'], true, true)
}

export { i18n }
