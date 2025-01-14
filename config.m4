PHP_ARG_ENABLE(pmmpthread, whether to enable pmmpthread,
[  --enable-pmmpthread          Enable pmmpthread])

PHP_ARG_WITH(pmmpthread-sanitize, whether to enable AddressSanitizer for pmmpthread,
[  --with-pmmpthread-sanitize   Enable AddressSanitizer for pmmpthread], no, no)

PHP_ARG_WITH(pmmpthread-dmalloc, whether to enable dmalloc for pmmpthread,
[  --with-pmmpthread-dmalloc   Enable dmalloc for pmmpthread], no, no)

if test "$PHP_PMMPTHREAD" != "no"; then
	AC_MSG_CHECKING([for ZTS])   
	if test "$PHP_THREAD_SAFETY" != "no"; then
		AC_MSG_RESULT([ok])
	else
		AC_MSG_ERROR([pmmpthread requires ZTS, please re-compile PHP with ZTS enabled])
	fi

	AC_DEFINE(HAVE_PMMPTHREAD, 1, [Whether you have pmmpthread support])

	if test "$PHP_PMMPTHREAD_SANITIZE" != "no"; then
		EXTRA_LDFLAGS="-lasan"
		EXTRA_CFLAGS="-fsanitize=address -fno-omit-frame-pointer"
	fi
	
	if test "$PHP_PMMPTHREAD_DMALLOC" != "no"; then
		EXTRA_LDFLAGS="$EXTRA_LDFLAGS -ldmalloc"
		EXTRA_CFLAGS="$EXTRA_CFLAGS -DDMALLOC"
	fi

	CLASSES_SRC="classes/pool.c classes/thread.c classes/thread_safe_array.c classes/thread_safe.c classes/runnable.c classes/worker.c"
	PHP_NEW_EXTENSION(pmmpthread, php_pmmpthread.c $CLASSES_SRC src/copy.c src/monitor.c src/worker.c src/globals.c src/prepare.c src/store.c src/handlers.c src/object.c src/routine.c src/queue.c src/ext_sockets_hacks.c, $ext_shared,, -DZEND_ENABLE_STATIC_TSRMLS_CACHE=1 -Werror=implicit-function-declaration)
	PHP_ADD_BUILD_DIR($ext_builddir/src, 1)
	PHP_ADD_INCLUDE($ext_builddir)

	PHP_ADD_EXTENSION_DEP(pmmpthread, sockets, true)

	PHP_SUBST(PMMPTHREAD_SHARED_LIBADD)
    PHP_SUBST(EXTRA_LDFLAGS)
    PHP_SUBST(EXTRA_CFLAGS)
	PHP_ADD_MAKEFILE_FRAGMENT
fi
