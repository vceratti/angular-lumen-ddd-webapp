# angular-lumen-ddd-webapp
A project for quick starting an web APP using Angular 2 and a REST API made with Lumen, using DDD and TDD (BDD?) and build/qa tools for continuous integration.
 
 - [Installation](#install)
 
 
# Work to do

This is a work in progress. The next steps are:

- start a Lumen Project project with a DDD structure (@davi)

- define rules, standards, build tools and more for JS (node, gulp, eslint, less/sass, bower, etc), plus the PHP Storm configs for integrations 

- start an Angular app project (find or create a DDD schema for angular?) and scaffold a sample page

- all the rest ... 

# Install


Clone this repository in your project folder and run the installer:

 ```bash
git clone https://github.com/vceratti/angular-lumen-ddd-webapp.git . &&
chmod +x ./new-project.sh &&
./new-project.sh
 ``` 

This installer will (may as for root permissions):

- Clean (if existing) the api folder and create a new one
- Ask for a project name, which will be used for docker containers, PHPStorm configs, etc...
- Check if git is installed (duh =S )
- Ask for environment options - 1 PHP 7.1 is preferable as 2 uses a deprecated container
- Download build repository 

- Optionally, makes a git-hook folder in your project and make the default commit git hook point into this new one (check?).  
