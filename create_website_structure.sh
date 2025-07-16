#!/bin/bash

# create_website_structure.sh
# This script creates a standard website directory structure with starter files

# Check if a project name was provided
if [ $# -eq 0 ]; then
    echo "Error: No project name provided."
    echo "Usage: $0 <project_name>"
    exit 1
fi

PROJECT_NAME=$1
echo "Creating website directory structure for project: $PROJECT_NAME"

# Create the project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create standard directories
mkdir -p css
mkdir -p js
mkdir -p images
mkdir -p pages
mkdir -p assets/fonts
mkdir -p assets/icons
mkdir -p vendor

# Create index.html with basic structure
cat > index.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>My Website</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" href="assets/icons/favicon.ico" type="image/x-icon">
</head>
<body>
    <header>
        <nav>
            <ul>
                <li><a href="index.html">Home</a></li>
                <li><a href="pages/about.html">About</a></li>
                <li><a href="pages/contact.html">Contact</a></li>
            </ul>
        </nav>
    </header>

    <main>
        <section>
            <h1>Welcome to My Website</h1>
            <p>This is a starter template for your website.</p>
        </section>
    </main>

    <footer>
        <p>&copy; 2025 My Website. All rights reserved.</p>
    </footer>

    <script src="js/script.js"></script>
</body>
</html>
EOL

# Create about.html
mkdir -p pages
cat > pages/about.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>About - My Website</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="icon" href="../assets/icons/favicon.ico" type="image/x-icon">
</head>
<body>
    <header>
        <nav>
            <ul>
                <li><a href="../index.html">Home</a></li>
                <li><a href="about.html">About</a></li>
                <li><a href="contact.html">Contact</a></li>
            </ul>
        </nav>
    </header>

    <main>
        <section>
            <h1>About Us</h1>
            <p>This is the about page of your website.</p>
        </section>
    </main>

    <footer>
        <p>&copy; 2025 My Website. All rights reserved.</p>
    </footer>

    <script src="../js/script.js"></script>
</body>
</html>
EOL

# Create contact.html
cat > pages/contact.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Contact - My Website</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="icon" href="../assets/icons/favicon.ico" type="image/x-icon">
</head>
<body>
    <header>
        <nav>
            <ul>
                <li><a href="../index.html">Home</a></li>
                <li><a href="about.html">About</a></li>
                <li><a href="contact.html">Contact</a></li>
            </ul>
        </nav>
    </header>

    <main>
        <section>
            <h1>Contact Us</h1>
            <form>
                <div>
                    <label for="name">Name:</label>
                    <input type="text" id="name" name="name" required>
                </div>
                <div>
                    <label for="email">Email:</label>
                    <input type="email" id="email" name="email" required>
                </div>
                <div>
                    <label for="message">Message:</label>
                    <textarea id="message" name="message" rows="5" required></textarea>
                </div>
                <button type="submit">Send Message</button>
            </form>
        </section>
    </main>

    <footer>
        <p>&copy; 2025 My Website. All rights reserved.</p>
    </footer>

    <script src="../js/script.js"></script>
</body>
</html>
EOL

# Create style.css
cat > css/style.css << 'EOL'
/* Reset some default styles */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: Arial, sans-serif;
    line-height: 1.6;
    color: #333;
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

header {
    background-color: #f4f4f4;
    padding: 20px;
    margin-bottom: 20px;
}

nav ul {
    display: flex;
    list-style: none;
}

nav ul li {
    margin-right: 20px;
}

nav ul li a {
    text-decoration: none;
    color: #333;
}

nav ul li a:hover {
    color: #0088cc;
}

main {
    min-height: 70vh;
}

section {
    margin-bottom: 30px;
}

h1 {
    margin-bottom: 20px;
    color: #0088cc;
}

p {
    margin-bottom: 15px;
}

footer {
    text-align: center;
    padding: 20px;
    background-color: #f4f4f4;
    margin-top: 20px;
}

/* Form styles */
form div {
    margin-bottom: 15px;
}

label {
    display: block;
    margin-bottom: 5px;
}

input, textarea {
    width: 100%;
    padding: 8px;
    border: 1px solid #ddd;
    border-radius: 4px;
}

button {
    background-color: #0088cc;
    color: white;
    border: none;
    padding: 10px 15px;
    border-radius: 4px;
    cursor: pointer;
}

button:hover {
    background-color: #006699;
}
EOL

# Create script.js
cat > js/script.js << 'EOL'
// Main JavaScript file

document.addEventListener('DOMContentLoaded', function() {
    console.log('Website loaded successfully!');
    
    // Example of a simple function
    function greet() {
        const currentHour = new Date().getHours();
        let greeting;
        
        if (currentHour < 12) {
            greeting = 'Good morning!';
        } else if (currentHour < 18) {
            greeting = 'Good afternoon!';
        } else {
            greeting = 'Good evening!';
        }
        
        console.log(greeting);
    }
    
    // Call the function
    greet();
    
    // Example of form handling (for contact page)
    const contactForm = document.querySelector('form');
    if (contactForm) {
        contactForm.addEventListener('submit', function(event) {
            event.preventDefault();
            
            const name = document.getElementById('name').value;
            const email = document.getElementById('email').value;
            const message = document.getElementById('message').value;
            
            console.log('Form submitted with the following data:');
            console.log('Name:', name);
            console.log('Email:', email);
            console.log('Message:', message);
            
            alert('Thank you for your message! We will get back to you soon.');
            contactForm.reset();
        });
    }
});
EOL

# Create a placeholder favicon
touch assets/icons/favicon.ico

# Create a README.md file
cat > README.md << 'EOL'
# Website Project

This is a basic website structure created with the `create_website_structure.sh` script.

## Directory Structure

- `css/` - Contains stylesheets
- `js/` - Contains JavaScript files
- `images/` - For image assets
- `pages/` - Additional HTML pages
- `assets/` - Other assets like fonts and icons
- `vendor/` - Third-party libraries

## Getting Started

1. Open `index.html` in your browser to view the website
2. Edit the HTML, CSS, and JavaScript files to customize your website
3. Add your own images to the `images/` directory
4. Add additional pages to the `pages/` directory as needed

## Features

- Responsive design
- Basic navigation
- Contact form template
- Modern CSS reset
- Simple JavaScript structure
EOL

echo "Website directory structure created successfully for project: $PROJECT_NAME"
echo "To view your website, navigate to the project directory and open index.html in a browser"
