# ShopIt - A Cross-Platform Shopping App

ShopIt is a cross-platform Flutter application that allows users to browse store details, view store locations on an interactive map, and manage shopping lists. The app integrates with Firebase Cloud Firestore for real-time data (store details, closing times, and item locations) and uses SharedPreferences for local data persistence (shopping lists).

## Features

- **Interactive Map:**
    - View store locations with item markers.
    - Automatically update the map based on the closest store to the user's current location.
    - Receive alerts when a store is nearing its closing time.

- **Store Details:**
    - Detailed store information including address, operating hours, description, images, and website links.
    - Ability to navigate from the store details screen back to the map with relevant data.

- **Shopping Lists:**
    - Create, update, and delete shopping lists.
    - Persist shopping list data locally using SharedPreferences.
    - Search functionality to filter items within a shopping list.

- **Data Persistence:**
    - **Firebase Cloud Firestore:** For dynamic store data such as store details, closing times, and item locations.
    - **SharedPreferences:** For local storage of user-generated shopping lists.

## Installation

1. **Clone the Repository:**
   ```bash
   git clone git@github.com:zachealy1/shopping_app.git
   cd shopit
    ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
    ```

3. **Run the App:**
   ```bash
   flutter run
    ```
