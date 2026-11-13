// ParkViet's layout for the signed-out pages (login, forgot/reset password,
// invitation, first-run setup). Replaces `@spree/dashboard`'s AuthShell, which
// shows Spree artwork, through the `parkvietAuthShell` plugin in vite.config.ts.
// Keep the export name and props identical to the shell's.
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import appIcon from '../assets/brand/parkviet-admin-app-icon.svg'
import markDark from '../assets/brand/parkviet-admin-mark-dark.svg'

export function AuthShell({ children }: { children: ReactNode }) {
  const { t } = useTranslation()

  return (
    <div className="grid min-h-svh lg:grid-cols-2">
      <div className="flex flex-col gap-6 bg-background p-6 md:p-10">
        <div className="flex items-center gap-3">
          <img src={appIcon} alt="" className="size-10" />
          <span className="text-lg font-semibold tracking-tight">{t('admin.app_name')}</span>
        </div>
        <div className="flex flex-1 items-center justify-center">
          <div className="flex w-full max-w-sm flex-col gap-6">{children}</div>
        </div>
      </div>
      <div className="relative hidden overflow-hidden bg-[#172d40] text-white lg:flex lg:flex-col lg:items-start lg:justify-end lg:p-14">
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0 opacity-[0.07] [background-image:radial-gradient(currentColor_1px,transparent_1px)] [background-size:24px_24px]"
        />
        <div
          aria-hidden
          className="pointer-events-none absolute -right-32 -top-32 size-[30rem] rounded-full bg-[#07569a]/60 blur-3xl"
        />
        <img
          src={markDark}
          alt=""
          className="pointer-events-none absolute right-[10%] top-[40%] h-[36%] -translate-y-1/2"
        />
        <div className="relative max-w-md space-y-3">
          <h2 className="text-3xl font-semibold leading-tight tracking-tight">
            {t('admin.auth_brand.headline')}
          </h2>
          <p className="text-base text-white/70">{t('admin.auth_brand.body')}</p>
        </div>
      </div>
    </div>
  )
}
