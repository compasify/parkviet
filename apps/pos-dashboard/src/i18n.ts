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
      welcomeBack: 'Welcome back',
      signInHint: 'Sign in with your administrator account to manage your stores.',
      loginFailed: 'Incorrect email or password. Please try again.',
      showPassword: 'Show password',
      hidePassword: 'Hide password',
      loginHeadline: 'Run every branch from one place',
      loginIntro: 'Set up the counters, keep the books straight and see how each branch is doing.',
      loginSecurity: 'Each account only sees the branches and screens it is allowed to.',
      forgotPasswordTitle: 'Reset your password',
      forgotPasswordIntro:
        'Enter your account email and we will send you a link to set a new password.',
      loginTasks: {
        branches: {
          title: 'Branches & registers',
          body: 'Open branches, set up registers, printers, scales and business modules.',
        },
        catalog: {
          title: 'Menu & products',
          body: 'Choose each branch’s assortment, prices, units and print templates.',
        },
        staff: {
          title: 'Staff & roles',
          body: 'Add staff, assign roles and limit what each can do.',
        },
        sales: {
          title: 'Orders & deliveries',
          body: 'Follow orders, deliveries and electronic invoices.',
        },
        money: {
          title: 'Funds & shifts',
          body: 'Reconcile cash funds, close shifts and settle receivables.',
        },
        reports: {
          title: 'Reports & inventory',
          body: 'Track revenue, stock and traceability per branch.',
        },
      },
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
      welcomeBack: 'Chào mừng trở lại',
      signInHint: 'Đăng nhập bằng tài khoản quản trị để quản lý cửa hàng của bạn.',
      loginFailed: 'Email hoặc mật khẩu không đúng. Vui lòng thử lại.',
      showPassword: 'Hiện mật khẩu',
      hidePassword: 'Ẩn mật khẩu',
      loginHeadline: 'Vận hành mọi chi nhánh từ một nơi',
      loginIntro: 'Thiết lập quầy bán, giữ sổ sách minh bạch và theo dõi tình hình từng chi nhánh.',
      loginSecurity: 'Mỗi tài khoản chỉ thấy chi nhánh và màn hình được cấp quyền.',
      forgotPasswordTitle: 'Đặt lại mật khẩu',
      forgotPasswordIntro: 'Nhập email tài khoản, chúng tôi sẽ gửi đường dẫn để đặt mật khẩu mới.',
      loginTasks: {
        branches: {
          title: 'Chi nhánh & quầy',
          body: 'Mở chi nhánh, thiết lập quầy thu ngân, máy in, cân và mô hình kinh doanh.',
        },
        catalog: {
          title: 'Thực đơn & sản phẩm',
          body: 'Chọn hàng bán, giá, đơn vị tính và mẫu in cho từng chi nhánh.',
        },
        staff: {
          title: 'Nhân viên & phân quyền',
          body: 'Thêm nhân viên, gán vai trò và giới hạn quyền thao tác.',
        },
        sales: {
          title: 'Đơn hàng & giao hàng',
          body: 'Theo dõi đơn hàng, giao hàng và hoá đơn điện tử.',
        },
        money: {
          title: 'Quỹ tiền & ca làm',
          body: 'Đối soát quỹ tiền mặt, chốt ca và thu hồi công nợ.',
        },
        reports: {
          title: 'Báo cáo & tồn kho',
          body: 'Theo dõi doanh thu, tồn kho và truy xuất nguồn gốc theo chi nhánh.',
        },
      },
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
