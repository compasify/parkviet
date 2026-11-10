import { createFileRoute } from '@tanstack/react-router'
import { ForgotPasswordPage } from '../pages/login'
export const Route = createFileRoute('/forgot-password')({ component: ForgotPasswordPage })
