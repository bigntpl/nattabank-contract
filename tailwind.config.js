module.exports = {
  content: ["./components/**/*.{js,jsx,ts,tsx}", "./pages/*.{js,jsx,ts,tsx}", "./components/styles/globals.css"],
  darkMode: false, // or 'media' or 'class'
  theme: {
    minHeight: {
      "more-detail-box": "240px",
    },
    extend: {
      transitionProperty: {
        "max-height": "max-height",
        filter: "filter",
      },
      colors: {
        gray: {
          350: "#828282",
        },
      },
      keyframes: {
        wiggle: {
          "0%, 100%": { transform: "rotate(-3deg)" },
          "50%": { transform: "rotate(3deg)" },
        },
        flyFade: {
          "0%": { opacity: 1 },
          "50%": { opacity: 0.9 },
          "100%": { transform: "translateX(50%) translateY(-50%)", opacity: 0 },
        },
      },
      animation: {
        wiggle: "wiggle 0.7s linear infinite",
        strongWiggle: "wiggle 0.2s linear infinite",
        flyFade: "flyFade 3s ease-out infinite",
      },
      spacing: {
        112: "28rem",
      },
    },
    fontSize: {
      "5xs": ".275rem",
      // '5xs': '.275rem',
      "4xs": [".375rem", { lineHeight: ".625rem" }],
      // '4xs': '.375rem',
      "3xs": [".5rem", { lineHeight: ".75rem" }],
      "3xs": ".5rem",
      "2xs": ".625rem",
      xs: ".75rem",
      sm: ".875rem",
      tiny: ".875rem",
      // base: ['1rem', { lineHeight: '1.25rem' }],
      base: "1rem",
      lg: "1.125rem",
      xl: "1.25rem",
      "2xl": "1.5rem",
      "3xl": "1.875rem",
      "4xl": "2.25rem",
      "5xl": "3rem",
      "6xl": "4rem",
      "7xl": "5rem",
      "8xl": "6rem",
    },
    zIndex: {
      100: "100",
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
