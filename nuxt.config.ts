// https://nuxt.com/docs/api/configuration/nuxt-config
import tailwindcss from "@tailwindcss/vite";

export default defineNuxtConfig({
  // 1. Ativa a estrutura de pastas e funcionalidades do Nuxt 4
  future: {
    compatibilityVersion: 4,
  },

  // 2. Adiciona o módulo do Supabase
  modules: ['@nuxtjs/supabase'],

  // 3. Configuração do Tailwind v4 via Vite
  css: ['~/assets/css/main.css'],
  vite: {
    plugins: [
      tailwindcss(),
    ],
  },

  // Configurações do Supabase (opcional: redirecionamento automático)
  supabase: {
    redirect: false, // Desabilita redirecionamento até configurar as credenciais
  },

  compatibilityDate: "2024-11-01",
  devtools: { enabled: true }
})
