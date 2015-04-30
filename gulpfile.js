// Generated on 2015-04-17 using generator-jhipster 2.7.0
/* jshint camelcase: false */
'use strict';

var gulp = require('gulp'),
    gutil = require('gulp-util'),
    prefix = require('gulp-autoprefixer'),
    minifyCss = require('gulp-minify-css'),
    usemin = require('gulp-usemin'),
    uglify = require('gulp-uglify'),
    compass = require('gulp-compass'),
    minifyHtml = require('gulp-minify-html'),
    imagemin = require('gulp-imagemin'),
    ngAnnotate = require('gulp-ng-annotate'),
    ngConstant = require('gulp-ng-constant-fork'),
    jshint = require('gulp-jshint'),
    rev = require('gulp-rev'),
    jade = require('gulp-jade'),
    tslint = require('gulp-tslint'),
    tsc = require('gulp-typescript'),
    proxy = require('proxy-middleware'),
    es = require('event-stream'),
    flatten = require('gulp-flatten'),
    del = require('del'),
    url = require('url'),
    htmllint = require('gulp-htmllint'),
    htmlhint = require("gulp-htmlhint"),
    wiredep = require('wiredep').stream,
    angularFilesort = require('gulp-angular-filesort'),
    inject = require('gulp-inject'),
    fs = require('fs'),
    runSequence = require('run-sequence'),
    browserSync = require('browser-sync');

var karma = require('gulp-karma')({configFile: 'src/test/javascript/karma.conf.js'});

var yeoman = {
    app: 'src/main/webapp/',
    dist: 'src/main/webapp/dist/',
    scripts: 'src/main/webapp/scripts/',
    javascript: 'src/main/javascript/',
    types: 'src/main/javascript/types/',
    test: 'src/test/javascript/spec/',
    tmp: '.tmp/',
    scss: 'src/main/',
    port: 9000,
    apiPort: 8080,
    liveReloadPort: 35729
};

var endsWith = function (str, suffix) {
    return str.indexOf('/', str.length - suffix.length) !== -1;
};

// Returns the second occurrence of the version number
var parseVersionFromBuildGradle = function() {
    var versionRegex = /^version\s*=\s*[',"]([^',"]*)[',"]/gm; // Match and group the version number
    var buildGradle = fs.readFileSync('build.gradle', 'utf8');
    return versionRegex.exec(buildGradle)[1];
};

gulp.task('clean', function (cb) {
  del([yeoman.dist], cb);
});

gulp.task('clean:tmp', function (cb) {
  del([yeoman.tmp], cb);
});

gulp.task('ts-lint', function () {
    return gulp.src(yeoman.scripts + '**/*.ts').pipe(tslint()).pipe(tslint.report('prose'));
});

gulp.task('ts-refs', function () {
    var target = gulp.src(yeoman.types + 'app.ts');
    
    var sources = gulp.src([
        yeoman.javascript + '**/*.ts',
        '!' + yeoman.types + '**/*.ts'
    ], {
        read: false
    });

    return target.pipe(inject(sources, {
        starttag: '//{',
        endtag: '//}',
        transform: function (filepath) {
            return '/// <reference path="' + filepath + '" />';
        },
        relative: true
    })).pipe(gulp.dest(yeoman.types));
});

gulp.task('ts-compile', ['ts-refs'], function () {
    var tsResult = gulp.src(yeoman.javascript + '**/*.ts')
           //          .pipe(sourcemaps.init())
                       .pipe(tsc({
                           target: 'ES5',
                           declarationFiles: false,
                           noExternalResolve: true
                       }));

        tsResult.dts.pipe(gulp.dest(yeoman.scripts));
        return tsResult.js
//                        .pipe(sourcemaps.write('.'))
                        .pipe(gulp.dest(yeoman.scripts));
});

gulp.task('test', ['wiredep:test', 'ngconstant:dev'], function() {
    karma.once();
});

gulp.task('copy', function() {
    return es.merge(gulp.src(yeoman.app + 'i18n/**').
              pipe(gulp.dest(yeoman.dist + 'i18n/')),
              gulp.src(yeoman.app + 'assets/**/*.{woff,svg,ttf,eot}').
              pipe(flatten()).
              pipe(gulp.dest(yeoman.dist + 'assets/fonts/')));
});

gulp.task('images', function() {
    return gulp.src(yeoman.app + 'assets/images/**').
        pipe(imagemin({optimizationLevel: 5})).
        pipe(gulp.dest(yeoman.dist + 'assets/images')).
        pipe(browserSync.reload({stream: true}));
});

gulp.task('compass', function() {
    return gulp.src(yeoman.scss + '**/*.scss').
        pipe(compass({
                project: __dirname,
                sass: 'src/main/scss',
                css: 'src/main/webapp/assets/styles',
                generated_images: '.tmp/images/generated',
                debug: false,
                environment: 'development',
                comments: true,
                image: 'src/main/webapp/assets/images',
                javascript: 'src/main/webapp/scripts',
                font: 'src/main/webapp/assets/fonts',
                import_path: 'src/main/webapp/bower_components',
                require: 'sass-globbing',
                relative: false
        })).
        pipe(gulp.dest(yeoman.tmp + 'styles'));
});

gulp.task('styles', ['compass'], function() {
    return gulp.src(yeoman.app + 'assets/styles/**/*.css').
        pipe(gulp.dest(yeoman.tmp)).
        pipe(browserSync.reload({stream: true}));
});

gulp.task('serve', function() {
    runSequence('wiredep:test', 'wiredep:app', 'inject', 'ngconstant:dev', 'compass', function () {
        var baseUri = 'http://localhost:' + yeoman.apiPort;
        // Routes to proxy to the backend. Routes ending with a / will setup
        // a redirect so that if accessed without a trailing slash, will
        // redirect. This is required for some endpoints for proxy-middleware
        // to correctly handle them.
        var proxyRoutes = [
            '/api',
            '/health',
            '/configprops',
            '/api-docs',
            '/metrics',
            '/dump/',
            '/oauth/token'
        ];

        var requireTrailingSlash = proxyRoutes.filter(function (r) {
            return endsWith(r, '/');
        }).map(function (r) {
            // Strip trailing slash so we can use the route to match requests
            // with non trailing slash
            return r.substr(0, r.length - 1);
        });

        var proxies = [
            // Ensure trailing slash in routes that require it
            function (req, res, next) {
                for (var route in requireTrailingSlash) {
                    if (url.parse(req.url).path === route) {
                        res.statusCode = 301;
                        res.setHeader('Location', route + '/');
                        res.end();
                    }
                    next();
                }
            }
        ].concat(
            // Build a list of proxies for routes: [route1_proxy, route2_proxy, ...]
            proxyRoutes.map(function (r) {
                var options = url.parse(baseUri + r);
                options.route = r;
                return proxy(options);
            }));

        browserSync({
            open: false,
            port: yeoman.port,
            server: {
                baseDir: yeoman.app,
                middleware: proxies
            }
        });

        gulp.run('watch');
    });
});

gulp.task('watch', function() {
    gulp.watch('bower.json', ['wiredep:test', 'wiredep:app']);
    gulp.watch(['Gruntfile.js', 'build.gradle'], ['ngconstant:dev']);
    gulp.watch(yeoman.scss + '**/*.scss', ['styles']);
    gulp.watch(yeoman.app + 'assets/images/**', ['images']);
    gulp.watch([yeoman.app + '*.html', yeoman.app + 'scripts/**']).on('change', browserSync.reload);
});

gulp.task('wiredep', ['wiredep:test', 'wiredep:app']);

gulp.task('wiredep:app', function () {
    var s = gulp.src('src/main/webapp/index.html')
        .pipe(wiredep({
            exclude: [/angular-i18n/, /swagger-ui/]
        }))
        .pipe(gulp.dest('src/main/webapp'));

    return es.merge(s, gulp.src('src/main/scss/main.scss')
        .pipe(wiredep({
            exclude: [
                /angular-i18n/,  // localizations are loaded dynamically
                /swagger-ui/,
                'bower_components/bootstrap/' // Exclude Bootstrap LESS as we use bootstrap-sass
            ],
            ignorePath: /\.\.\/webapp\/bower_components\// // remove ../webapp/bower_components/ from paths of injected sass files
        }))
        .pipe(gulp.dest('src/main/scss')));
});

gulp.task('wiredep:test', function () {
    return gulp.src('src/test/javascript/karma.conf.js')
        .pipe(wiredep({
            exclude: [/angular-i18n/, /swagger-ui/, /angular-scenario/],
            ignorePath: /\.\.\/\.\.\//, // remove ../../ from paths of injected javascripts
            devDependencies: true,
            fileTypes: {
                js: {
                    block: /(([\s\t]*)\/\/\s*bower:*(\S*))(\n|\r|.)*?(\/\/\s*endbower)/gi,
                    detect: {
                        js: /'(.*\.js)'/gi
                    },
                    replace: {
                        js: '\'{{filePath}}\','
                    }
                }
            }
        }))
        .pipe(gulp.dest('src/test/javascript'));
});

gulp.task('inject', function () {
    return gulp.src('src/main/webapp/index.html').pipe(
        inject(gulp.src('src/main/webapp/scripts/**/*.js').pipe(angularFilesort()), {
            relative: true                                             
        })
    ).pipe(gulp.dest('src/main/webapp'));
});

gulp.task('build', function () {
    runSequence('clean', 'copy', 'wiredep:app', 'inject', 'ngconstant:prod', 'usemin');
});

gulp.task('usemin', function() {
    runSequence('images', 'styles', function () {
        return gulp.src([yeoman.app + '**/*.html', '!' + yeoman.app + 'bower_components/**/*.html']).
            pipe(usemin({
                css: [
                    prefix.apply(),
                    minifyCss({root: 'src/main/webapp'}),  // Replace relative paths for static resources with absolute path with root
                    'concat', // Needs to be present for minifyCss root option to work
                    rev()
                ],
                html: [
                    minifyHtml({empty: true, conditionals:true})
                ],
                js: [
                    ngAnnotate(),
                    uglify(),
                    'concat',
                    rev()
                ]
            })).
            pipe(gulp.dest(yeoman.dist));
    });
});

gulp.task('ngconstant:dev', function() {
    return ngConstant({
        dest: 'constants.js',
        name: 'csrsApp',
        deps:   false,
        noFile: true,
        interpolate: /\{%=(.+?)%\}/g,
        wrap: '/* jshint quotmark: false */\n"use strict";\n// DO NOT EDIT THIS FILE, EDIT THE GULP TASK NGCONSTANT SETTINGS INSTEAD WHICH GENERATES THIS FILE\n{%= __ngModule %}',
        constants: {
            ENV: 'dev',
            VERSION: parseVersionFromBuildGradle()
        }
    }).pipe(gulp.dest(yeoman.app + 'scripts/app/config/'));
});

gulp.task('ngconstant:prod', function() {
    return ngConstant({
        dest: 'constants.js',
        name: 'csrsApp',
        deps:   false,
        noFile: true,
        interpolate: /\{%=(.+?)%\}/g,
        wrap: '/* jshint quotmark: false */\n"use strict";\n// DO NOT EDIT THIS FILE, EDIT THE GULP TASK NGCONSTANT SETTINGS INSTEAD WHICH GENERATES THIS FILE\n{%= __ngModule %}',
        constants: {
            ENV: 'prod',
            VERSION: parseVersionFromBuildGradle()
        }
    }).pipe(gulp.dest(yeoman.tmp + 'scripts/app/config/'));
});

gulp.task('jade', function () {
    return gulp.src(yeoman.javascript + '**/*.jade').pipe(jade({
        pretty: true
    })).pipe(gulp.dest(yeoman.scripts));
});

gulp.task('clean:scripts', function (cb) {
    del([yeoman.scripts], cb);
});

gulp.task('copy:scripts', function () {
    return gulp.src([
        yeoman.javascript + '**/*',
        '!**/*.jade',
        '!**/*.ts',
        '!**/*.scss'
    ]).pipe(
        gulp.dest(yeoman.scripts)
    );
});

gulp.task('build:scripts', ['copy:scripts', 'jade', 'ts-compile', 'compass']); 

gulp.task('scripts', ['clean:scripts'], function () {
    runSequence('build:scripts', 'inject');
});

gulp.task('copy', function() {
    return es.merge(
        gulp.src(
            yeoman.app + 'i18n/**'
        ).pipe(
            gulp.dest(yeoman.dist + 'i18n/')
        ),
              
        gulp.src(
            yeoman.app + 'assets/**/*.{woff,svg,ttf,eot}'
        ).pipe(
            flatten()
        ).pipe(
            gulp.dest(yeoman.dist + 'assets/fonts/')
        )
    );
});

gulp.task('jshint', function() {
    return gulp.src(['gulpfile.js', yeoman.app + 'scripts/**/*.js'])
        .pipe(jshint())
        .pipe(jshint.reporter('jshint-stylish'));
});

gulp.task('htmllint', function () {
    return gulp.src(
        ['src/main/webapp/index.html', yeoman.app + 'scripts/**/*.html']
    ).pipe(htmllint());
});

gulp.task('htmlhint', function () {
    return gulp.src(
        ['src/main/webapp/index.html', yeoman.app + 'scripts/**/*.html']
    ).pipe(htmlhint({
        'doctype-first': false
    })).pipe(htmlhint.reporter());
});

gulp.task('server', ['serve'], function () {
    gutil.log('The `server` task has been deprecated. Use `gulp serve` to start a server');
});

gulp.task('default', function() {
    runSequence('test', 'build');
});
