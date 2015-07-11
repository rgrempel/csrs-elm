// Generated on 2015-04-17 using generator-jhipster 2.7.0
/* jshint camelcase: false */
'use strict';

var gulp = require('gulp');

gulp.task('clean', ['clean:elm'], function (cb) {
    var del = require('del');
    
    del('build/resources/main/public', cb);
});

gulp.task('clean:elm', function (cb) {
    var del = require('del');
    
    del('elm-stuff/build-artifacts', cb);
});

gulp.task('web', function (cb) {
    var mkdirp = require('mkdirp');
    
    mkdirp('build/resources/main/public', '0775', function () {
        cb();
    });
});

gulp.task('app.js', ['web'], function (cb) {
    var exec = require('child_process').exec;
    
    exec('elm-make src/main/elm/App.elm --warn --output build/resources/main/public/app.js', function (err, stdout, stderr) {
        console.log(stdout);
        console.log(stderr);
        cb(err);
    });
});

gulp.task('test', function (cb) {
    var exec = require('child_process').exec;
    
    exec('elm-make src/main/elm/Test.elm --warn --output build/test.html', function (err, stdout, stderr) {
        console.log(stdout);
        console.log(stderr);

        exec('open build/test.html');
        cb(err);
    });
});

gulp.task('bower', ['web'], function (cb) {
    var exec = require('child_process').exec;
    
    exec('./node_modules/bower/bin/bower install', function (err, stdout, stderr) {
        console.log(stdout);
        console.log(stderr);
        cb(err);
    });
});

gulp.task('scss:dir', function (cb) {
    var mkdirp = require('mkdirp');
    
    mkdirp('build/scss', '0775', function () {
        cb();
    });
});

gulp.task('scss:inject', ['scss:dir'], function () {
    var inject = require('gulp-inject');
    var sort = require('gulp-sort');

    return gulp.src('src/main/web/main.scss').pipe(
        inject(gulp.src([
            'src/main/elm/**/*.scss'
        ], {
            read: false
        }).pipe(
            sort()
        ), {
            starttag: '// inject:scss',
            endtag: '// endinject',
            relative: false,
            transform: function (filepath, file, i, length) {
                return '@import "../..' + filepath + '";';
            }
        })
    ).pipe(
        gulp.dest('build/scss')
    );
});

gulp.task('scss:compile', ['scss:inject'], function (cb) {
    var sass = require('node-sass');
    var fs = require('fs');

    sass.render({
        file: 'build/scss/main.scss',
    }, function (err, result) {
        if (err) {
            console.log(JSON.stringify(err, null, 4));
            cb();
        } else {
            fs.writeFile('build/scss/main.css', result.css, cb);
        }
    });
});

gulp.task('prefix', ['scss:compile'], function () {
    var prefix = require('gulp-prefix');

    return gulp.src(
        'build/scss/main.css'
    ).pipe(
        prefix()
    ).pipe(
        gulp.dest('build/resources/main/public')
    );
});

gulp.task('index.html', ['web', 'bower'], function () {
    var wiredep = require('wiredep').stream;
    
    return gulp.src(
        'src/main/web/index.html'
    ).pipe(
        wiredep({
            ignorePath: '../../../build/resources/main/public/'
        })
    ).pipe(
        gulp.dest('build/resources/main/public')
    );
});

gulp.task('images', ['web'], function () {
    return gulp.src('src/main/elm/**/*.jpg').pipe(
        gulp.dest('build/resources/main/public/images')
    );
});

gulp.task('default', ['app.js', 'index.html', 'prefix', 'images']);

