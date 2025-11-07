Summary
-------

This repository contains a web application and a background worker that allows users to anonymously submit tweets via a web form. The submitted tweets are queued in a database and posted to a configured Twitter account at a regular interval.

Motivation / Purpose
--------------------

Not available in repository.

Key features
------------

-   **Web-based Submission**: Provides a simple web form for users to submit tweet content.
-   **Tweet Queuing**: Submitted tweets are stored in a SQLite database, acting as a queue.
-   **Automated Posting**: A background thread periodically fetches the oldest tweet from the queue and posts it to a designated Twitter account using the Twitter API.
-   **Character Limit Validation**: Enforces Twitter's 280-character limit on the server side before accepting a submission.
-   **Configurable Interval**: The time interval between posts can be configured via an environment variable.
-   **Environment-based Configuration**: Twitter API keys and other settings are managed through environment variables.

Project structure
-----------------

-   `main.py`: The main entry point for the application, which starts the Flask web server and the background tweeting thread.
-   `app.py`: Defines the Flask application and its routes, including the submission form (`/`) and the form handler (`/submit`).
-   `database.py`: Manages all interactions with the SQLite database, including creating the table and queuing/dequeuing tweets.
-   `tweeting.py`: Handles authentication with the Twitter API via Tweepy and the logic for posting tweets.
-   `templates/`: Contains the HTML template for the web submission form.
-   `static/`: Contains the CSS stylesheet for the web interface.
-   `requirements.txt`: A list of Python package dependencies.
-   `Procfile`: A configuration file for deployment on platforms like Heroku.
-   `.env.example`: An example file outlining the required environment variables.

Technology stack
----------------

-   **Language**: Python
-   **Web Framework**: Flask
-   **Web Server**: Gunicorn
-   **Twitter Integration**: Tweepy
-   **Database**: SQLite