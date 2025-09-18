# Spring Boot Demo Application

A simple demonstration application built with Spring Boot and Thymeleaf templating engine, matching the functionality and design of the existing Flask and Ktor demo applications.

## Features

- **Spring Boot 3.2.1**: Modern Java web framework with auto-configuration
- **Thymeleaf**: Server-side templating engine for dynamic HTML generation
- **Responsive Design**: Clean, modern layout with gradient background
- **Hot Reload**: Spring Boot DevTools for automatic application restart during development

## Structure

```
src/
├── main/
│   ├── java/
│   │   └── com/sourcegraph/revenue/
│   │       ├── Application.java      # Main Spring Boot application class
│   │       └── HomeController.java   # Controller with GET / route
│   └── resources/
│       └── templates/
│           ├── layout.html          # Base Thymeleaf template
│           └── index.html           # Home page template
```

## Running the Application

The application can be started using the demo management system:

```bash
# From the amp_demos directory
./demo.sh start java spring-boot
```

Or run directly:

```bash
# From this directory
./start_demo.sh
```

The application will start on `http://localhost:8080`.

## Technology Stack

- **Java 21**: Modern Java LTS version
- **Spring Boot**: Framework for production-ready applications
- **Thymeleaf**: Natural templating for web applications
- **Spring Web MVC**: Model-View-Controller web framework
- **Gradle**: Build automation tool

## Template Features

- Template inheritance using Thymeleaf fragments
- Dynamic content rendering
- CSS styling matching Flask/Ktor demos
- Responsive layout design
