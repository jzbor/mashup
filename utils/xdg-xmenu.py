#!/bin/python3

from pathlib import Path
import argparse
import os, os.path
import shutil
import subprocess
import sys

XDG_DATA_HOME       = os.getenv('XDG_DATA_HOME', os.path.join(os.getenv('HOME'), '.local/share'))
XDG_CONFIG_HOME     = os.getenv('XDG_CONFIG_HOME', os.path.join(os.getenv('HOME'), '.config'))
XDG_DATA_DIRS       = set(os.getenv('XDG_DATA_DIRS', '/usr/share:/usr/local/share').split(':'))
APPLICATION_DIRS    = set([os.path.join(dir, 'applications') for dir in XDG_DATA_DIRS.copy()]\
                        + [os.path.join(XDG_DATA_HOME, 'applications')])
CACHE_DIR           = os.path.join(os.getenv('XDG_CACHE_HOME',
                        os.path.join(os.getenv('HOME'), '.cache')), 'xdg-xmenu-py')
MULTIPLE_CATEGORIES = True
SORT_BY_CATEGORY    = True
COMPILE_IMAGES      = True
FORCE_REFRESH_CACHE = False

imagefiles = []
icontheme = ''
applications = []
categories= {
    "Multimedia": set(),
    "Development": set(),
    "Education": set(),
    "Games": set(),
    "Graphics": set(),
    "Network": set(),
    "Office": set(),
    "Science": set(),
    "Settings": set(),
    "System": set(),
    "Utility": set(),
    "Other": set(),
}

class Application:
    categories = []
    execute = ''
    genname = ''
    iconname = ''
    iconpath = ''
    name = ''
    terminal = False
    nodisplay = False
    onlyshowin = ''

    def format(self):
        out = ''
        if self.iconpath != '':
            out += 'IMG:{}\t'.format(self.iconpath)
        out += self.name
        if self.genname != '':
            out += ' ({})'.format(self.genname)
        out += '\t{}'.format(self.execute)
        return out

def get_image_files():
    filelist = []
    for icondir in [os.path.join(dd, 'icons') for dd in XDG_DATA_DIRS]:
        for root, dirs, files in os.walk(icondir):
            for f in files:
                file = os.path.join(root, f)
                if os.path.isfile(file):
                    filelist.append(file)
    return filelist

def get_icon_theme():
    path = os.path.join(XDG_CONFIG_HOME, 'gtk-3.0/settings.ini')
    if os.path.isfile(path):
        file = open(path, 'r')
        for line in file.readlines():
            if 'gtk-icon-theme-name' in line:
                return line.strip().split('=')[1]
    return False


def load_icon(name, ext, path):
    if not os.path.isdir(CACHE_DIR):
        os.makedirs(CACHE_DIR)
    dest = os.path.join(CACHE_DIR, name + '.png')
    if ext in ('png'):
        shutil.copyfile(path, dest)
    else:
        proc = subprocess.Popen(['convert', path, '-alpha', 'on', dest], stdout=subprocess.PIPE)
        proc.wait()
    if os.path.isfile(dest):
        return dest
    else:
        return ''


def set_icon(app):
    global imagefiles, icontheme
    name = app.iconname
    if not FORCE_REFRESH_CACHE and (os.path.isfile(os.path.join(CACHE_DIR, name + '.png'))):
        app.iconpath = os.path.join(CACHE_DIR, name + '.png')
    elif not FORCE_REFRESH_CACHE and (os.path.isfile(os.path.join(CACHE_DIR, name + '.notfound'))):
        pass
    elif COMPILE_IMAGES or FORCE_REFRESH_CACHE:
        image_found = False
        if imagefiles == []:
            imagefiles = get_image_files()
        if icontheme == '':
            icontheme = get_icon_theme()
        for imagefile in imagefiles:
            for ext in ['png', 'svg']:
                if imagefile.endswith('/{}.{}'.format(name, ext)) \
                        and (app.iconpath == '' or icontheme in imagefile):
                    app.iconpath = load_icon(name, ext, imagefile)
                    print("{}.png <= {}".format(name, imagefile), file=sys.stderr)
                    image_found = True
        if not image_found:
            Path(os.path.join(CACHE_DIR, name + '.notfound')).touch()
            print("=> {}.notfound".format(name), file=sys.stderr)


def dict_to_application(dictionary:dict):
    app = Application()
    app.name = dictionary['Name']
    app.execute = dictionary['Exec']
    if 'GenericName' in dictionary:
        app.genname = dictionary['GenericName']
    if 'Icon' in dictionary:
        app.iconname = os.path.basename(dictionary['Icon'])
        set_icon(app)
    if 'Categories' in dictionary:
        app.categories = dictionary['Categories'].split(';')
    if 'Terminal' in dictionary:
        app.terminal = dictionary['Terminal'] in ('true', 'True')
    if 'NoDisplay' in dictionary:
        app.nodisplay = dictionary['NoDisplay'] in ('true', 'True')
    if 'OnlyShowIn' in dictionary:
        app.onlyshowin = dictionary['OnlyShowIn'].split(';')

    if SORT_BY_CATEGORY:
        added = False
        for cat in app.categories:
            if cat in categories:
                categories[cat].add(app)
                added = True
            elif 'Video' in cat or 'Audio' in cat:
                categories['Multimedia'].add(app)
                added = True
            elif 'Game' in cat:
                categories['Games'].add(app)
                added = True
            elif 'Network' in cat:
                categories['Internet'].add(app)
                added = True
            if added and not MULTIPLE_CATEGORIES:
                break
        if not added:
            categories['Other'].add(app)

    return app


def load_desktop_file(filepath):
    file = open(filepath, 'r')
    application = {}
    for line in file.readlines():
        try:
            key, value = line.strip().split('=', 2)
            # cancel before additional options are added
            if key in application:
                break
            application[key] = value
        except: pass
    try:
        applications.append(dict_to_application(application))
    except KeyError: pass


def load_desktop_files():
    for directory in APPLICATION_DIRS:
        if not os.path.isdir(directory):
            continue
        for subfile in os.listdir(directory):
            filepath = os.path.join(directory, subfile)
            if os.path.islink(filepath):
                filepath = os.readlink(filepath)
            if os.path.isfile(filepath):
                load_desktop_file(filepath)


def format_xmenu(applications):
    if SORT_BY_CATEGORY:
        for cat, apps in categories.items():
            print(cat)
            for app in apps:
                if not app.nodisplay and app.onlyshowin == '':
                    print('\t{}'.format(app.format()))
    else:
        for app in applications:
            print(app.format())


def parse_args():
    parser = argparse.ArgumentParser(description='Generate application menu in xmenu format')
    parser.add_argument('-m', '--multiple', help='Add applications to multiple categories',
                        action='store_true', dest='multiple_categories')
    parser.add_argument('-a', '--applications', help='Don\'t sort applications by category',
                        action='store_false', dest='sort_by_category')
    parser.add_argument('-l', '--lazy', help='Don\'t compile images on demand (this is way faster)',
                        action='store_false', dest='compile_images')
    parser.add_argument('-f', '--force', help='Force refresh image cache',
                        action='store_true', dest='force_refresh_cache')
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args()
    MULTIPLE_CATEGORIES = args.multiple_categories
    SORT_BY_CATEGORY = args.sort_by_category
    COMPILE_IMAGES = args.compile_images
    FORCE_REFRESH_CACHE = args.force_refresh_cache
    load_desktop_files()
    format_xmenu(applications)

# for app in applications:
#     if app.name == 'Spotify':
#         print(app.categories)
