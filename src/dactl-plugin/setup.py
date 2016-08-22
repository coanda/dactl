from os import path
from setuptools import setup
from setuptools.command.egg_info import egg_info

SRC_PATH = path.relpath(path.join(path.dirname(__file__), "."))

# Class to handle the build step
class EggInfoCommand(egg_info):
    def run(self):
        if "build" in self.distribution.command_obj:
            build_command = self.distribution.command_obj["build"]
            self.egg_base = build_command.build_base
            self.egg_info = path.join(self.egg_base, path.basename(self.egg_info))
        egg_info.run(self)

# Utility function to read the README file.
def read(fname):
    return open(path.join(path.dirname(__file__), fname)).read()

d = setup(
    name = "dactl-plugin",
    version = "0.1.0",
    author = "Geoff Johnson",
    author_email = "geoff.jay@gmail.com",

    description = ("Utility to simplify the creation of new plugins for Dactl."),
    long_description = read('README.md'),

    url = "http://packages.python.org/geoffjay/dactl-plugin",
    license = "MIT",

    keywords = "utility",
    packages = ['dactl_plugin'],
    package_dir = {
        "": SRC_PATH,
    },
    entry_points = {
        'console_scripts': [
            'dactl-plugin = dactl_plugin.__main__:main'
        ]
    },

    cmdclass = {
        "egg_info": EggInfoCommand,
    },

    install_requires = [
        "Jinja2 >= 2.8",
    ],

    classifiers = [
        "Development Status :: 1 - Planning",
        "Environment :: Console",
        "Topic :: Utilities",
        "License :: OSI Approved :: MIT License",
    ],
)

print(d.get_option_dict('install_path'))
print(d.get_option_dict('local_path'))
