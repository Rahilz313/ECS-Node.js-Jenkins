FROM node:16-alpine  
# Use Node.js version 16 with Alpine Linux (lightweight)

WORKDIR /app  
# Set the working directory within the container

COPY package*.json ./  
# Copy package.json file

RUN npm install  
# Install any dependencies listed in package.json (none in this case)

COPY . .  
# Copy all files from the current directory (including index.js)

EXPOSE 3000  
# Expose port 3000, which the application listens on

CMD [ "node", "index.js" ]  
# Set the default command to start the application
