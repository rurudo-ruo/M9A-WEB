export interface Locale {
  name: string
  // displayName: string
  htmlLang: string
  siteTitle: string
  siteDescription: string
}

export const locales: Locale[] = [
  {
    name: 'zh_cn',
    // displayName: '简体中文',
    htmlLang: 'zh-CN',
    siteTitle: 'MAA 文档站',
    siteDescription: '文档',
  },
  {
    name: 'en_us',
    // displayName: 'English',
    htmlLang: 'en-US',
    siteTitle: 'MAA Documentation Site',
    siteDescription: 'Documentation',
  },
]