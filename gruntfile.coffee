fs = require 'fs'

rankingSort = (a, b) ->
  if a.ranking < b.ranking then 1
  else if a.ranking > b.ranking then -1
  else 0

getProjectLinkList = ->
  projectLinkList = []
  renderedProjectLinkList = ''
  projectList = fs.readdirSync('src/projects')
  linkTemplate = fs.readFileSync('src/projectLink.html')+''
  for projectName, i in projectList
    projectInfo = JSON.parse fs.readFileSync('./src/projects/'+projectName+'/project.json')
    if projectInfo.link
      link = 'http://'+projectInfo.link
    else
      link = 'projects/'+projectName
    renderedLink = linkTemplate.replace('<link>', link)
    renderedLink = renderedLink.replace('<title>', projectInfo.title)
    renderedLink = renderedLink.replace('<shortDesc>', projectInfo.shortDesc)
    renderedLink = renderedLink.replace('<desc>', projectInfo.desc||"")
    renderedLink = renderedLink.replace('<imgLink>', 'screenshots/'+projectName+'.png')

    projectLinkList.push
      html: renderedLink
      ranking: projectInfo.ranking

  projectLinkList.sort(rankingSort)

  for projectData in projectLinkList
    renderedProjectLinkList += projectData.html
  '<div class="projectLinkList">'+renderedProjectLinkList+'</div>'

module.exports = (grunt)->
  require('load-grunt-tasks')(grunt)
  grunt.loadNpmTasks('assemble-less')

  grunt.initConfig

    coffeelint:
      compile:
        options:
          'no_trailing_whitespace':
            'level': 'error'
        files: src: ['src/*.coffee']

    coffeescript_concat:
      compile:
        options: bare: false
        files:[
          'src/projects/space_dodger/main.coffee': ['src/projects/space_dodger/**/*.coffee']
          'src/projects/c64_textmode/main.coffee': ['src/projects/c64_textmode/**/*.coffee']
        ]

    coffee:
      main:
        files: [
          src: 'src/mainpage/*.coffee', dest: 'public/main.js'
        ]
      sharedScripts:
        options:
          bare: true
        files: [
          expand: true
          cwd: 'src'
          src: ['sharedScripts/**/*.coffee']
          dest: 'public/'
          ext: '.js'
        ]
      projects:
        options:
          join: true
          bare: false
        files: [
          expand: true
          flatten: false
          cwd: 'src/projects'
          src: ['*/*.coffee']
          dest: 'public/projects/'
          ext: '.js'
        ]

    less:
      main:
        files: [
          src: 'src/mainpage/*.less', dest: 'public/main.css'
        ]
      projects:
        expand: true
        cwd: 'src/projects'
        src: ['**/main.less']
        dest: 'public/projects/'
        ext: '.css'

    copy:
      main:
        files:[
          src: 'src/mainpage/index.html', dest: 'public/index.html'
        ]
      imgs:
        expand: true
        cwd: 'src/mainpage/'
        src: ['img/*.*']
        dest: 'public/'
      screenshots:
        expand: true
        cwd: 'src/screenshots/'
        src: ['*.png']
        dest: 'public/screenshots'
      assets:
        expand: true
        cwd: 'src/projects/'
        src: ['**/assets/*.*']
        dest: 'public/projects'
      favicon: files: [
        'public/favicon.ico': 'src/mainpage/favicon.ico'
        'public/favicon.png': 'src/mainpage/favicon.png'
      ]
      projects:
        expand: true
        cwd: 'src/projects'
        src: ['**/*.html']
        dest: 'public/projects/'
        ext: '.html'

    'string-replace':
      backBtn2projecthtml:
        options:
          replacements: [
            pattern: '</body>', replacement: grunt.file.read('src/back.html')
          ]
        files: [
          expand: true
          cwd: 'src/projects'
          src: ['**/*.html']
          dest: 'public/projects/'
        ]
      addLinklist2homepage:
        options:
          replacements: [
            pattern: '<projectlist>'
            replacement: getProjectLinkList()
          ]
        files: [
          src: ['public/index.html']
          dest: 'public/index.html'
        ]

    ftp_push:
      options:
        host: 'e91391-ftp.services.easyname.eu'
        authKey: 'easynameSaylermorph'
        dest: '/'
        incrementalUpdates: true
        debug: false
        hideCredentials: true
      upload:
        files: [
          expand: true
          cwd: './public'
          src: ['*.*', '**/*.*']
        ]

    browserSync:
      bsFiles:
        src : './public/*.*'
      options:
        watchTask: true
        server: "./public"

    watch:
      files: ['./src/**/*.*', 'gruntfile.coffee']
      tasks: ['build']



  grunt.registerTask 'default', ['doAll']
  grunt.registerTask 'ftp', ['ftp_push']
  grunt.registerTask 'build', ['coffeelint', 'coffeescript_concat', 'coffee', 'less', 'copy', 'string-replace']
  grunt.registerTask 'doAll', ['build', 'browserSync', 'watch']
