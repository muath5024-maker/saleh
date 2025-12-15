/**
 * Store Themes Configuration
 * 3 base themes with customizable UI tokens
 */

export interface Theme {
  id: string;
  name: string;
  description: string;
  colors: {
    primary: string;
    secondary: string;
    accent: string;
    background: string;
    surface: string;
    text: string;
    textSecondary: string;
  };
  typography: {
    fontFamily: string;
    headingFont: string;
  };
  components: {
    button: {
      borderRadius: string;
      padding: string;
    };
    card: {
      borderRadius: string;
      shadow: string;
    };
  };
}

export const themes: Theme[] = [
  {
    id: 'modern',
    name: 'عصري',
    description: 'تصميم عصري وأنيق مع ألوان زاهية',
    colors: {
      primary: '#2563EB',
      secondary: '#7C3AED',
      accent: '#059669',
      background: '#FFFFFF',
      surface: '#F9FAFB',
      text: '#111827',
      textSecondary: '#6B7280',
    },
    typography: {
      fontFamily: 'Inter, sans-serif',
      headingFont: 'Inter, sans-serif',
    },
    components: {
      button: {
        borderRadius: '12px',
        padding: '12px 24px',
      },
      card: {
        borderRadius: '16px',
        shadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
      },
    },
  },
  {
    id: 'classic',
    name: 'كلاسيكي',
    description: 'تصميم كلاسيكي وأنيق مع ألوان هادئة',
    colors: {
      primary: '#1F2937',
      secondary: '#4B5563',
      accent: '#DC2626',
      background: '#FFFFFF',
      surface: '#F3F4F6',
      text: '#111827',
      textSecondary: '#6B7280',
    },
    typography: {
      fontFamily: 'Georgia, serif',
      headingFont: 'Georgia, serif',
    },
    components: {
      button: {
        borderRadius: '4px',
        padding: '10px 20px',
      },
      card: {
        borderRadius: '8px',
        shadow: '0 2px 4px rgba(0, 0, 0, 0.1)',
      },
    },
  },
  {
    id: 'minimal',
    name: 'بسيط',
    description: 'تصميم بسيط وحديث مع تركيز على المحتوى',
    colors: {
      primary: '#000000',
      secondary: '#666666',
      accent: '#000000',
      background: '#FFFFFF',
      surface: '#FAFAFA',
      text: '#000000',
      textSecondary: '#666666',
    },
    typography: {
      fontFamily: 'Helvetica, Arial, sans-serif',
      headingFont: 'Helvetica, Arial, sans-serif',
    },
    components: {
      button: {
        borderRadius: '0px',
        padding: '12px 32px',
      },
      card: {
        borderRadius: '0px',
        shadow: 'none',
      },
    },
  },
];

export function getTheme(themeId: string): Theme | null {
  return themes.find((t) => t.id === themeId) || null;
}

export function applyThemeStyles(theme: Theme): string {
  return `
    :root {
      --color-primary: ${theme.colors.primary};
      --color-secondary: ${theme.colors.secondary};
      --color-accent: ${theme.colors.accent};
      --color-background: ${theme.colors.background};
      --color-surface: ${theme.colors.surface};
      --color-text: ${theme.colors.text};
      --color-text-secondary: ${theme.colors.textSecondary};
      --font-family: ${theme.typography.fontFamily};
      --font-heading: ${theme.typography.headingFont};
      --button-radius: ${theme.components.button.borderRadius};
      --button-padding: ${theme.components.button.padding};
      --card-radius: ${theme.components.card.borderRadius};
      --card-shadow: ${theme.components.card.shadow};
    }
  `;
}
