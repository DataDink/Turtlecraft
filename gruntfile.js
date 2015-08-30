module.exports = function(grunt) {
   var luamin = require('luamin/luamin.js');

   grunt.initConfig({
      concat: {
         options: { separator: ';\r\n\r\n' },
         turtlecraft: {
            src: [
               // core
               '../ModCraft/lua/Builds/modcraft.lua',
            ],
            dest: 'Builds/turtlecraft.lua'
         }
      },
      minify: {
         turtlecraft: {
            src: 'Builds/turtlecraft.lua',
            dest: 'Builds/turtlecraft.min.lua'
         }
      }
   });

   grunt.registerMultiTask('minify', 'Minifies Lua', function() {
      this.files.forEach(function(f) {
         var raw = grunt.file.read(f.src);
         var min = luamin.minify(raw);
         grunt.file.write(f.dest, min);
      });
   });
   grunt.loadNpmTasks('grunt-contrib-concat');
   grunt.registerTask('build-all', ['concat', 'minify']);
};
