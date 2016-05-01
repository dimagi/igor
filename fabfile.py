from fabric.api import local, run, sudo, cd, env, task, execute
from fabric.colors import blue, red, white, green

# the user to use for the remote commands
# the servers where the commands are executed
env.hosts = ['hqcaptain0.internal.commcarehq.org']
env.code_root = '/home/cchq/igor/src'
env.sudo_user = 'cchq'


def update_code():
    with cd(env.code_root):
        sudo('git remote prune origin')
        sudo('git pull origin master')
        sudo("git clean -ffd")


def install_deps():
    with cd(env.code_root):
        sudo('npm install')


@task
def restart_services():
    sudo('sudo supervisorctl restart igor-express')


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

