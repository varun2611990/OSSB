import {
  createUnifiedTheme,
  palettes,
  genPageTheme,
} from '@backstage/theme';

// Cool color palette based on modern design trends
const coolPalette = {
  ...palettes.light,
  type: 'light' as const,
  mode: 'light' as const,
  primary: {
    main: '#6366f1', // Indigo primary
    dark: '#4f46e5',
    light: '#818cf8',
  },
  secondary: {
    main: '#f59e0b', // Amber secondary  
    dark: '#d97706',
    light: '#fbbf24',
  },
  background: {
    default: '#fafafa',
    paper: '#ffffff',
  },
  // Enhanced navigation with gradient backgrounds
  navigation: {
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    indicator: '#6366f1',
    color: '#ffffff',
    selectedColor: '#fbbf24',
    navItem: {
      hoverBackground: 'rgba(255, 255, 255, 0.1)',
    },
    submenu: {
      background: 'rgba(255, 255, 255, 0.95)',
    },
  },
  // Cool accent colors
  status: {
    ok: '#10b981', // Green
    warning: '#f59e0b', // Amber  
    error: '#ef4444', // Red
    running: '#3b82f6', // Blue
    pending: '#8b5cf6', // Purple
    aborted: '#6b7280', // Gray
  },
  // Enhanced UI colors
  link: '#6366f1',
  linkHover: '#4f46e5',
  highlight: 'rgba(99, 102, 241, 0.1)',
  border: '#e5e7eb',
  textContrast: '#111827',
  textVerySubtle: '#9ca3af',
  textSubtle: '#6b7280',
  gold: '#f59e0b',
  errorBackground: '#fef2f2',
  warningBackground: '#fffbeb',
  infoBackground: '#eff6ff',
  errorText: '#dc2626',
  infoText: '#2563eb',
  warningText: '#d97706',
  // Cool banner colors
  banner: {
    info: '#dbeafe',
    error: '#fee2e2',
    text: '#111827',
    link: '#6366f1',
    closeButtonColor: '#6b7280',
    warning: '#fef3c7',
  },
  // Cool sidebar button
  pinSidebarButton: {
    icon: '#6b7280',
    background: '#f3f4f6',
  },
  tabbar: {
    indicator: '#6366f1',
  },
};

// Cool page themes with modern gradients
const coolPageThemes = {
  home: genPageTheme({
    colors: ['#667eea', '#764ba2'],
    shape: 'none',
    options: {
      fontColor: '#ffffff',
    },
  }),
  documentation: genPageTheme({
    colors: ['#f093fb', '#f5576c'],
    shape: 'none',
    options: {
      fontColor: '#ffffff',  
    },
  }),
  tool: genPageTheme({
    colors: ['#4facfe', '#00f2fe'],
    shape: 'none',
    options: {
      fontColor: '#ffffff',
    },
  }),
  service: genPageTheme({
    colors: ['#43e97b', '#38f9d7'],
    shape: 'none',
    options: {
      fontColor: '#ffffff',
    },
  }),
  website: genPageTheme({
    colors: ['#fa709a', '#fee140'],
    shape: 'none',
    options: {
      fontColor: '#ffffff',
    },
  }),
  library: genPageTheme({
    colors: ['#a8edea', '#fed6e3'],
    shape: 'none',
    options: {
      fontColor: '#111827',
    },
  }),
  other: genPageTheme({
    colors: ['#667eea', '#764ba2'],
    shape: 'none',
    options: {
      fontColor: '#ffffff',
    },
  }),
};

// Enhanced component themes with animations
const coolComponentThemes = {
  MuiButton: {
    styleOverrides: {
      root: {
        borderRadius: '8px',
        textTransform: 'none' as const,
        fontWeight: 600,
        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
        '&:hover': {
          transform: 'translateY(-2px)',
          boxShadow: '0 10px 25px rgba(99, 102, 241, 0.3)',
        },
        '&:active': {
          transform: 'translateY(0)',
        },
      },
      contained: {
        background: 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)',
        '&:hover': {
          background: 'linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%)',
        },
      },
      outlined: {
        borderWidth: '2px',
        '&:hover': {
          borderWidth: '2px',
          background: 'rgba(99, 102, 241, 0.05)',
        },
      },
    },
  },
  MuiCard: {
    styleOverrides: {
      root: {
        borderRadius: '12px',
        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
        border: '1px solid #e5e7eb',
        '&:hover': {
          transform: 'translateY(-4px)',
          boxShadow: '0 20px 40px rgba(0, 0, 0, 0.1)',
          borderColor: '#6366f1',
        },
      },
    },
  },
  MuiPaper: {
    styleOverrides: {
      root: {
        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
      },
      elevation1: {
        boxShadow: '0 2px 8px rgba(0, 0, 0, 0.1)',
      },
      elevation2: {
        boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
      },
      elevation3: {
        boxShadow: '0 8px 24px rgba(0, 0, 0, 0.15)',
      },
    },
  },
  MuiListItem: {
    styleOverrides: {
      root: {
        borderRadius: '8px',
        transition: 'all 0.2s cubic-bezier(0.4, 0, 0.2, 1)',
        '&:hover': {
          backgroundColor: 'rgba(99, 102, 241, 0.08)',
          transform: 'translateX(4px)',
        },
      },
    },
  },
  MuiChip: {
    styleOverrides: {
      root: {
        borderRadius: '6px',
        transition: 'all 0.2s cubic-bezier(0.4, 0, 0.2, 1)',
        '&:hover': {
          transform: 'scale(1.05)',
        },
      },
      filled: {
        background: 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)',
        color: '#ffffff',
      },
    },
  },
  MuiIconButton: {
    styleOverrides: {
      root: {
        borderRadius: '8px',
        transition: 'all 0.2s cubic-bezier(0.4, 0, 0.2, 1)',
        '&:hover': {
          backgroundColor: 'rgba(99, 102, 241, 0.1)',
          transform: 'scale(1.1)',
        },
      },
    },
  },
  MuiTab: {
    styleOverrides: {
      root: {
        textTransform: 'none' as const,
        fontWeight: 500,
        transition: 'all 0.2s cubic-bezier(0.4, 0, 0.2, 1)',
        '&:hover': {
          color: '#6366f1',
          transform: 'translateY(-1px)',
        },
      },
    },
  },
  MuiLinearProgress: {
    styleOverrides: {
      root: {
        borderRadius: '4px',
        backgroundColor: '#e5e7eb',
      },
      bar: {
        borderRadius: '4px',
        background: 'linear-gradient(90deg, #6366f1 0%, #8b5cf6 100%)',
      },
    },
  },
};

export const coolTheme = createUnifiedTheme({
  palette: coolPalette,
  defaultPageTheme: 'home',
  pageTheme: coolPageThemes,
  fontFamily: '"Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
  components: coolComponentThemes,
});