#!/bin/bash

# Step 1: Generate utils.py
echo "Setting up utils.py..."
cat <<EOL > reverie/backend_server/utils.py
# Copy and paste your OpenAI API Key
openai_api_key = "<Your OpenAI API>"
# Put your name
key_owner = "<Name>"

maze_assets_loc = "../../environment/frontend_server/static_dirs/assets"
env_matrix = f"{maze_assets_loc}/the_ville/matrix"
env_visuals = f"{maze_assets_loc}/the_ville/visuals"

fs_storage = "../../environment/frontend_server/storage"
fs_temp_storage = "../../environment/frontend_server/temp_storage"

collision_block_id = "32125"

# Verbose 
debug = True
EOL
echo "Please update 'reverie/backend_server/utils.py' with your OpenAI API key and name."

# Step 2: Install requirements.txt
echo "Setting up virtual environment and installing dependencies..."
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt

# Step 3: Start the Environment Server
echo "Starting the environment server..."
cd environment/frontend_server
python manage.py runserver &
ENV_SERVER_PID=$!
echo "Environment server started on http://localhost:8000/. Keep this running for the simulation."

# Step 4: Start the Simulation Server
echo "Starting the simulation server..."
cd ../../reverie/backend_server
python reverie.py &
SIM_SERVER_PID=$!
echo "Simulation server started. Please follow the prompts to initiate the simulation."

# Wait for user input for simulation name
read -p "Enter the name of the forked simulation (e.g., base_the_ville_isabella_maria_klaus): " forked_simulation
read -p "Enter the name of the new simulation (e.g., test-simulation): " new_simulation

# Input simulation names
echo "$forked_simulation" > reverie.py_input.txt
echo "$new_simulation" >> reverie.py_input.txt

# Step 5: Run the Simulation
echo "Running simulation..."
cd ../../environment/frontend_server/static_dirs
open http://localhost:8000/simulator_home

# Instructions for controlling the simulation
echo "Simulation setup complete! Follow the instructions below to continue:"
echo "1. On the simulation server, type 'run <step-count>' to start the simulation (e.g., run 100 for 100 steps)."
echo "2. To stop the servers, press Ctrl+C in each terminal window."
echo "3. To replay, go to http://localhost:8000/replay/<simulation-name>/<starting-time-step>."
echo "4. To demo, use http://localhost:8000/demo/<simulation-name>/<starting-time-step>/<simulation-speed>."

# Cleanup
trap "kill $ENV_SERVER_PID $SIM_SERVER_PID" EXIT
