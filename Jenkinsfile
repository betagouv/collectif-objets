pipeline {

    environment {
        RAILS_ENV = 'test'
        DATABASE_URL = 'postgres://rails:password@localhost:5432/rails_test'
        DISABLE_BOOTSNAP = '1'
    }

    agent { label "dev" }

    services {
        postgres {
            image 'postgres:14'
            env {
                POSTGRES_DB = 'rails_test'
                POSTGRES_USER = 'rails'
                POSTGRES_PASSWORD = 'password'
            }
            ports {
                port 5432
            }
        }
    }



    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'sudo apt-get update && sudo apt-get install -y libvips'
                ruby.setup(
                    versions: ['3.1'],
                    bundlerCache: true
                )
                sh 'npm ci'
            }
        }

        stage('Setup Database') {
            steps {
                sh 'bin/rails db:schema:load'
            }
        }

        stage('Run Tests') {
            steps {
                dir('tmp/artifacts/capybara') {
                    sh 'bundle exec rspec'
                }
                archiveArtifacts 'tmp/artifacts/capybara/**/*'
            }
        }

        stage('Lint') {
            steps {
                ruby.lint(
                    rubyCriteria: [
                        'rubocop --parallel'
                    ]
                )
            }
        }

    }
}