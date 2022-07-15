module.exports = {
  plugins: [
    require('postcss-import')({
      path: ['src/frontend']
    }),
    require('postcss-preset-env')({
      stage: 2,
      browsers: [
        '>0.3%',
        'Firefox ESR',
        'not dead',
        'not ie 11',
        'not op_mini all'
      ],
      features: {
        'custom-properties': {
          strict: false,
          warnings: false,
          preserve: true
        },
        'custom-media-queries': true
      }
    }),
    require('postcss-reporter')
  ]
}
