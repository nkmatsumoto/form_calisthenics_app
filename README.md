## Form - A calisthenics workout tracker that records videos of your form

App home: https://form-calisthenics-app.onrender.com
<br><br>
Form is a calisthenics workout tracker that allows you to record video your exercises, store them as part of your workout log and compare to your your past performance.

<img width="200" alt="Screenshot 2024-09-03 at 13 22 30" src="https://github.com/user-attachments/assets/746aa035-8260-4a86-8c6d-cb8685ffbc2a">
<img width="200" alt="Screenshot 2024-09-03 at 13 22 53" src="https://github.com/user-attachments/assets/1e522023-6b33-44bc-ad91-7a5bab946a5b">
<img width="200" alt="Screenshot 2024-09-03 at 13 24 32" src="https://github.com/user-attachments/assets/5d0c40ab-44ae-415b-b5c6-2ba100b3e240">
<img width="200" alt="Screenshot 2024-09-03 at 13 25 03" src="https://github.com/user-attachments/assets/b76c4791-a4b1-427b-b61b-d09f967fec50">



   

## Getting Started
### Setup

Install gems
```
bundle install
```

### ENV Variables
Create `.env` file
```
touch .env
```
Inside `.env`, set these variables. For any APIs, see group Slack channel.
```
CLOUDINARY_URL=your_own_cloudinary_url_key
```

### DB Setup
```
rails db:create
rails db:migrate
rails db:seed
```

### Run a server
```
rails s
```

## Built With
- [Rails 7](https://guides.rubyonrails.org/) - Backend / Front-end
- [Stimulus JS](https://stimulus.hotwired.dev/) - Front-end JS
- [Render](https://render.com/) - Deployment
- [Neon](https://neon.tech/) - PostgreSQL database
- [PostgreSQL](https://www.postgresql.org/) - Database
- [Bootstrap](https://getbootstrap.com/) — Styling
- [Figma](https://www.figma.com) — Prototyping

## Deployment notes
Hosting moved from Heroku to Render + Neon. See:
- [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md) — current production setup
- [`docs/MIGRATION_REPORT.md`](docs/MIGRATION_REPORT.md) — migration details and verification
- [`CHANGELOG.md`](CHANGELOG.md) — recent changes

## Acknowledgements
Inspired by many calisthenics content creators I have been following over the years

## Team Members
- [Nicholas Matsumoto](https://www.linkedin.com/in/nicholas-matsumoto-18596a7b/)
- [Chaewan Shin](https://github.com/chaeshin)
- [Ryo Imakoa](https://github.com/rimaoka18)

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License
