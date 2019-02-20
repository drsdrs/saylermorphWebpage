fs = require 'fs'

getProjectLinkList = ->
  projectLinkList = ''
  projectList = fs.readdirSync('src/projects')
  linkTemplate = fs.readFileSync('src/projectLink.html')+''
  for projectName in projectList
    renderedLink = linkTemplate.replace('<link>', 'projects/'+projectName+'/index.html')
    renderedLink = renderedLink.replace('<linkname>', projectName.replace(/_/g, ' '))

    projectLinkList += renderedLink

  '<div class="projectLinkList">'+projectLinkList+'</div>'

module.exports = (grunt)->

  grunt.initConfig
  
    coffeelint:
      compile:
        options:
          'no_trailing_whitespace':
            'level': 'error'
        files: src: ['src/*.coffee']
  
    coffee:
      main:
        files: [
          src: 'src/mainpage/*.coffee', dest: 'public/main.js'
        ]
        
      projects:
        options:
          join: true
          bare: true
        files: [
          expand: true
          cwd: 'src/projects'
          src: ['**/*.coffee']
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
        src: ['**/*.less']
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


    browserSync:
      bsFiles:
        src : './public/*.*'
      options:
        watchTask: true
        server: "./public"
        
    watch:
      files: ['./src/**/*.*', 'gruntfile.coffee']
      tasks: ['build']
      
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('assemble-less')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-string-replace')
  grunt.loadNpmTasks('grunt-browser-sync')
  
  grunt.registerTask 'default', ['doAll']
  grunt.registerTask 'build', ['coffeelint', 'coffee', 'less', 'copy', 'string-replace']
  grunt.registerTask 'doAll', ['build', 'browserSync', 'watch']
