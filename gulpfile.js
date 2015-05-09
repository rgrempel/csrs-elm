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
    sort = require('gulp-sort'),
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
    yaml = require('js-yaml'),
    _ = require('lodash'),
    Stream = require('streamjs'),
    through2 = require('through2'),
    Vinyl = require('vinyl'),
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

gulp.task('clean', ['clean:scripts'], function (cb) {
    del([yeoman.dist], cb);
});

gulp.task('clean:tmp', function (cb) {
    del([yeoman.tmp], cb);
});

gulp.task('clean:scripts', function (cb) {
    del([yeoman.scripts], cb);
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
    var tsResult = gulp.src(
        yeoman.javascript + '**/*.ts'
    // ).pipe(
        // sourcemaps.init()
    ).pipe(
        tsc({
            noImplicitAny: true,                 
            target: 'ES5',
            declarationFiles: false,
            noExternalResolve: true
        })
    );

    tsResult.dts.pipe(
        gulp.dest(yeoman.javascript + 'types/csrs/')
    );

    return tsResult.js.pipe(
        // sourcemaps.write('.')
    // ).pipe(
        gulp.dest(yeoman.scripts)
    );
});

gulp.task('test', ['wiredep:test', 'ngconstant:dev'], function() {
    karma.once();
});

gulp.task('copy', function() {
    return es.merge(
        gulp.src(yeoman.app + 'i18n/**').pipe(
            gulp.dest(yeoman.dist + 'i18n/')
        ),

        gulp.src(yeoman.app + 'assets/**/*.{woff,svg,ttf,eot}').pipe(
            flatten()
        ).pipe(
            gulp.dest(yeoman.dist + 'assets/fonts/')
        )
    );
});

gulp.task('images', function() {
    return gulp.src(
        yeoman.app + 'assets/images/**'
    ).pipe(
        imagemin({optimizationLevel: 5})
    ).pipe(
        gulp.dest(yeoman.dist + 'assets/images')
    ).pipe(
        browserSync.reload({stream: true})
    );
});

gulp.task('compass', function() {
    return gulp.src(
        yeoman.scss + '**/*.scss'
    ).pipe(
        compass({
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
        })
    ).pipe(
        gulp.dest(yeoman.tmp + 'styles')
    );
});

gulp.task('prefix', ['compass'], function() {
    return gulp.src(
        yeoman.app + 'assets/styles/**/*.css'
    ).pipe(
        prefix()
    ).pipe(
        gulp.dest(yeoman.app + 'assets/styles')
    );
});

gulp.task('styles', ['prefix'], function() {
    return gulp.src(
        yeoman.app + 'assets/styles/**/*.css'
    ).pipe(
        gulp.dest(yeoman.tmp)
    ).pipe(
        browserSync.reload({stream: true})
    );
});

gulp.task('serve', function() {
    runSequence('wiredep:test', 'wiredep:app', 'scripts', 'ngconstant:dev', function () {
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
            })
        );

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
    gulp.watch(['gulpfile.js', 'build.gradle'], ['ngconstant:dev']);
    gulp.watch(yeoman.scss + '**/*.scss', ['styles']);
    gulp.watch(yeoman.app + 'assets/images/**', ['images']);
    gulp.watch([yeoman.app + '*.html', yeoman.app + 'scripts/**']).on('change', browserSync.reload);
});

gulp.task('wiredep', ['wiredep:test', 'wiredep:app']);

gulp.task('wiredep:app', function () {
    return es.merge(
        gulp.src(
            'src/main/webapp/index.html'
        ).pipe(
            wiredep({
                exclude: [/angular-i18n/, /swagger-ui/]
            })
        ).pipe(
            gulp.dest('src/main/webapp')
        ),

        gulp.src(
            'src/main/scss/main.scss'
        ).pipe(
            wiredep({
                exclude: [
                    /angular-i18n/,  // localizations are loaded dynamically
                    /swagger-ui/,
                    'bower_components/bootstrap/' // Exclude Bootstrap LESS as we use bootstrap-sass
                ],

                ignorePath: /\.\.\/webapp\/bower_components\// // remove ../webapp/bower_components/ from paths of injected sass files
            })
        ).pipe(
            gulp.dest('src/main/scss')
        )
    );
});

gulp.task('wiredep:test', function () {
    return gulp.src(
        'src/test/javascript/karma.conf.js'
    ).pipe(
        wiredep({
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
        })
    ).pipe(
        gulp.dest('src/test/javascript')
    );
});

gulp.task('inject', ['scripts', 'translations'], function () {
    return gulp.src(
        'src/main/webapp/index.html'
    ).pipe(
        inject(
            gulp.src(
                'src/main/webapp/scripts/**/*.js'
            ).pipe(
                // Do a regular sort first, since angularFilesort by itself
                // does not seem to be deterministic.
                sort()
            ).pipe(
                angularFilesort()
            ), 
            
            {relative: true}
        )
    ).pipe(
        gulp.dest('src/main/webapp')
    );
});

gulp.task('build', function () {
    runSequence('clean', 'copy', 'wiredep:app', 'inject', 'ngconstant:prod', 'usemin');
});

gulp.task('usemin', ['images', 'styles', 'scripts'], function() {
    return gulp.src([
        yeoman.app + '**/*.html',
        '!' + yeoman.app + 'bower_components/**/*.html']
    ).pipe(
        usemin({
            css: [
                prefix.apply(),
                minifyCss({
                    // Replace relative paths for static resources with absolute path with root
                    root: 'src/main/webapp'
                }),
                'concat', // Needs to be present for minifyCss root option to work
                rev()
            ],

            html: [
                minifyHtml({
                    empty: true,
                    conditionals: true
                })
            ],

            js: [
                ngAnnotate(),
                uglify(),
                'concat',
                rev()
            ]
        })
    ).pipe(
        gulp.dest(yeoman.dist)
    );
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
    }).pipe(
        gulp.dest(yeoman.app + 'scripts/app/config/')
    );
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
    }).pipe(
        gulp.dest(yeoman.tmp + 'scripts/app/config/')
    );
});

gulp.task('jade', function () {
    return gulp.src(
        yeoman.javascript + '**/*.jade'
    ).pipe(
        jade({
            pretty: true
        })
    ).pipe(
        gulp.dest(yeoman.scripts)
    );
});

gulp.task('copy:scripts', function () {
    return gulp.src([
        yeoman.javascript + '**/*.js',
        yeoman.javascript + '**/*.html'
    ]).pipe(
        gulp.dest(yeoman.scripts)
    );
});

gulp.task('scripts', ['copy:scripts', 'jade', 'ts-compile', 'styles']); 

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
    return gulp.src([
        'gulpfile.js',
        yeoman.app + 'scripts/**/*.js'
    ]).pipe(
        jshint()
    ).pipe(
        jshint.reporter('jshint-stylish')
    );
});

gulp.task('htmllint', function () {
    return gulp.src([
        'src/main/webapp/index.html',
        yeoman.app + 'scripts/**/*.html'
    ]).pipe(
        htmllint()
    );
});

gulp.task('htmlhint', function () {
    return gulp.src([
        'src/main/webapp/index.html',
        yeoman.app + 'scripts/**/*.html'
    ]).pipe(
        htmlhint({
            'doctype-first': false
        })
    ).pipe(
        htmlhint.reporter()
    );
});

gulp.task('server', ['serve'], function () {
    gutil.log('The `server` task has been deprecated. Use `gulp serve` to start a server');
});
    
gulp.task('messages', function (cb) {
    var doc = yaml.safeLoad(
        fs.readFileSync('src/main/i18n/messages.yml', {
            encoding: 'utf8'
        })
    );

    var products = yaml.safeLoad(
        fs.readFileSync('src/main/i18n/products.yml', {
            encoding: 'utf8'
        })
    );

    _.assign(doc, products);

    var result = {};
    var keys = [];

    var iterate = function (level) {
        _.forOwn(level, function (value, key) {
            if (_.isObject(value)) {
                keys.push(key);
                iterate(value);
                keys.pop(key);
            } else {
                if (!_.has(result, key)) result[key] = [];
                var line = keys.join('.') + '=' + value;
                result[key].push(line);
            }
        });
    };
    
    iterate(doc);
    
    _.forOwn(result, function (value, key) {
        var filename = 'src/main/resources/i18n/messages_' + key + '.properties';
        var data = value.join("\n") + "\n";
        fs.writeFileSync(filename, data);
    });

    cb();
});

gulp.task('translations', function () {
    return gulp.src([
        'src/main/i18n/translations.yml',
        'src/main/i18n/products.yml',
        yeoman.javascript + '**/*.language.yml'
    ]).pipe(
        translations()
    ).pipe(
        gulp.dest(yeoman.app + 'i18n/')
    );
});

function translations () {
    var doc = {};

    return through2.obj(transform, flush);

    function transform (file, encoding, cb) {
        if (file.isBuffer()) {
            _.assign(doc, yaml.safeLoad(file.contents.toString()));
        }

        if (file.isStream()) {
            this.emit('error', new gutil.PluginError("translations", 'Streams not supported!')); 
        }

        cb();
    }

    function flush (cb) {
        var result = {};
        var keys = [];

        var iterate = function (level) {
            _.forEach(_.sortBy(_.keys(level)), function (key) {
                var value = level[key];
            
                if (_.isObject(value)) {
                    keys.push(key);
                    iterate(value);
                    keys.pop();
                } else {
                    if (!_.has(result, key)) result[key] = {};
                    var base = result[key];
                    _.forEach(_.initial(keys), function (eachKey) {
                        if (!_.has(base, eachKey)) base[eachKey] = {};
                        base = base[eachKey];
                    });
                    base[_.last(keys)] = value;
                }
            });
        };

        var self = this;
        
        iterate(doc);

        _.forOwn(result, function (value, key) { 
            var file = new Vinyl({
                path: key + '.json',
                contents: new Buffer(JSON.stringify(value, null, 4))
            });

            self.push(file);
        });

        this.push(null);
        cb();
    }    
}

gulp.task('default', function() {
    runSequence('test', 'build');
});
