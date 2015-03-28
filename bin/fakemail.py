#!/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Resources/Python.app/Contents/MacOS/Python
#
# fakemail (Python version)
#
# $Id: fakemail.py,v 1.4 2011/06/09 16:57:10 ashtong Exp $


import asyncore
import getopt
import os
import signal
import smtpd
import socket
import sys


class FakeServer(smtpd.SMTPServer):

    RECIPIENT_COUNTER = {}

    def __init__(self, localaddr, remoteaddr, path):
        smtpd.SMTPServer.__init__(self, localaddr, remoteaddr)
        self.path = path

    def process_message(self, peer, mailfrom, rcpttos, data):
        message("Incoming mail")
        for recipient in rcpttos:
            message("Capturing mail to %s" % recipient)
            count = self.RECIPIENT_COUNTER.get(recipient, 0) + 1
            self.RECIPIENT_COUNTER[recipient] = count
            filename = os.path.join(self.path, "%s.%s" % (recipient, count))
            filename = filename.replace("<", "").replace(">", "")
            f = file(filename, "w")
            f.write(data + "\n")
            f.close()
            message("Mail to %s saved" % recipient)
        message("Incoming mail dispatched")


def script_name():
    return os.path.basename(sys.argv[0])


def usage():
    print "Usage: %s [OPTIONS]" % script_name()
    print """
OPTIONS
        --host=<localdomain>
        --port=<port number>
        --path=<path to save mails>
        --log=<optional file to append messages to>
        --background"""


def quit(reason=None):
    global progname
    text = "Stopping %s" % progname
    if reason is not None:
        text += ": %s" % reason
    message(text)
    sys.exit()


log_file = None


def message(text):
    global log_file
    if log_file is not None:
        f = file(log_file, "a")
        f.write(text + "\n")
        f.close()
    else:
        print text


def handle_signals():
    for name in ("SIGINT", "SIGTERM", "SIGHUP"):
        try:
            sig = getattr(signal, name)
        except AttributeError:  # SIGHUP not available on some platforms
            pass
        else:
            signal.signal(sig, lambda signmum, frame: quit())


def read_command_line():
    global log_file
    try:
        optlist, args = getopt.getopt(
            sys.argv[1:], "", ["host=", "port=", "path=", "log=", "background"])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    # Set defaults
    host = "localhost"
    port = 8025
    path = os.getcwd()
    background = False
    for opt, arg in optlist:
        if opt == "--host":
            host = arg
        elif opt == "--port":
            port = int(arg)
        elif opt == "--path":
            path = arg
        elif opt == "--log":
            log_file = arg
        elif opt == "--background":
            background = True
    return host, port, path, background


def become_daemon():
    # See "Python Standard Library", pg. 29, O'Reilly, for more
    # info on the following.
    try:
        pid = os.fork()
    except AttributeError:
        print("INFO: --background is unsupported on this platform")
        if sys.platform.find("win") >= 0:
            print("INFO: Start %s with pythonw.exe instead" % script_name())
    else:
        if pid:  # we're the parent if pid is set
            os._exit(0)
        os.setpgrp()
        os.umask(0)

        class DevNull:
            def write(self, message):
                pass

        sys.stdin.close()
        sys.stdout = DevNull()
        sys.stderr = DevNull()


def main():
    global progname
    handle_signals()
    host, port, path, background = read_command_line()
    message("Starting %s" % progname)
    if background:
        become_daemon()
    try:
        server = FakeServer((host, port), None, path)
    except socket.error, e:
        quit(str(e))
    message("Listening on port %d" % port)
    try:
        asyncore.loop()
    except KeyboardInterrupt:
        quit()


if __name__ == "__main__":
    progname = os.path.basename(sys.argv[0])
    main()
