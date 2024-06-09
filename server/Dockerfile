FROM dart:stable AS build
WORKDIR /app

# Copy the entire project to the container
COPY . .

# Get dependencies
RUN dart pub get

# Create the bin directory
RUN mkdir -p bin

# Compile the application
RUN dart compile exe .dart_frog/server.dart -o bin/server

# Build minimal production image from build output
FROM subfuzion/dart:slim
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/
COPY --from=build /app/pubspec.yaml /app/
COPY --from=build /app/.dart_frog /app/.dart_frog/

# Expose the port used by server
EXPOSE 8080

# Set the working directory
WORKDIR /app

# Run the server executable
CMD ["/app/bin/server"]
