# Use Node.js base image
FROM node:10

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application
COPY . .

# Expose the port the app will run on
EXPOSE 3000

# Set the environment variable for SECRET_WORD
ENV SECRET_WORD=your_secret_here

# Start the application
CMD ["node", "index.js"]
