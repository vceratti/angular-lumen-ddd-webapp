# angular-lumen-ddd-webapp
A project for quick starting an web APP using Angular 2 and a REST API made with Lumen, using DDD and TDD (BDD?) and build/qa tools for continuous integration.
 
 - [Installation](#install)
 
 
# Work to do

This is a work in progress. The next steps are:
  
- start a PHP Storm Project using predefined code style settings for PHP auto formatting and several validations. 
 including PHPCS for PSR-2 and PHPMD with many pre-defined rules for clean code. PHP build tools are checked out from this project which uses Docker images with all the tools used. 

- start a Lumen Project project with a DDD scruture (@davi)

- define rules, standards, build tools and more for JS (node, gulp, eslint, less/sass, bower, etc), plus the PHP Storm configs for integrations 

- start an Angular app project (find or create a DDD schema for angular?) and scaffold a sample page

- all the rest ... 

# Install

  Run install.sh to: 
- Create an api folder
- Download build tools and runs another automated installer, which checks/install Ant and Docker and copy build toolds and docker-compose config into api folder
- Optionally, makes a git-hook folder in your project and make the default commig git hook point into this new one (check?).  
