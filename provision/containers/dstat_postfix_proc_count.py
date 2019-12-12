
class dstat_plugin(dstat):
    """
    Total Number of postfix processes on this system.
    """
    def __init__(self):
        self.name = 'pprocs'
        self.vars = ('total',)
        self.type = 'd'
        self.width = 4
        self.scale = 10

    def extract(self):
        import commands
        cmd = '/bin/ps ax | /bin/grep "[/]usr/lib/postfix/sbin/master" | /usr/bin/wc -l'
        self.val['total'] = int(commands.getoutput(cmd))
