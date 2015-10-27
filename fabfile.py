from fabric.api import local, run, sudo, cd, env, task, execute
from fabric.colors import blue, red, white, green

# the user to use for the remote commands
env.user = 'dimagi'
# the servers where the commands are executed
env.hosts = ['162.242.212.212']
env.code_root = '/var/lib/mia/mia'


def pack():
    # create a new source distribution as tarball
    local('python setup.py sdist --formats=gztar', capture=False)


def update_code():
    with cd(env.code_root):
        sudo('git remote prune origin')
        sudo('git pull origin master')
        sudo("git clean -ffd")


@task
def restart_services():
    sudo('supervisorctl restart mia', user='root')


@task
def deploy():
    print green('''
        ,---.    ,---..-./`)    ____
    |    \  /    |\ .-.') .'  __ `.
    |  ,  \/  ,  |/ `-' \/   '  \  \\
    |  |\_   /|  | `-'`"`|___|  /  |
    |  _( )_/ |  | .---.    _.-`   |
    | (_ o _) |  | |   | .'   _    |
    |  (_,_)  |  | |   | |  _( )_  |
    |  |      |  | |   | \ (_ o _) /
    '--'      '--' '---'  '.(_,_).'
    ''')
    print white('You are now deploying Mia!!')
    try:
        execute(update_code)
        execute(restart_services)
    except Exception, e:
        print red('Mia has failed to deploy')

