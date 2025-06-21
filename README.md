# MinimalAuthExample

A minimal Swift backend example for user registration, login, and authenticated data access using JWT tokens.

For the sake of simplicity, a file store has been used for data persistency.

This project was built to learn the basics of backend development and JWT authentication in Swift, using [Hummingbird](https://github.com/hummingbird-project/hummingbird) and [JWTKit](https://github.com/vapor/jwt-kit).

## Features

- ✅ User registration with hashed passwords (using Bcrypt)
- ✅ User login with password verification
- ✅ JWT-based authentication
- ✅ Create and retrieve user-specific recipes
- ✅ Tested use cases and HTTP endpoints

## Endpoints

- `POST /register`: Register a new user (returns JWT token)
- `POST /login`: Authenticate a user (returns JWT token)
- `POST /recipes`: Create a recipe (requires Bearer token)
- `GET /recipes`: Fetch recipes for authenticated user

## Notes

- For simplicity, the project uses dependency injection via function closures (not protocols).
- JSON files are stored in a custom path using `.cachesDirectory`.

## License

MIT
