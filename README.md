# Form Calisthenics (archive)

Form is a calisthenics workout tracker that records exercise videos, stores them in a workout log, and compares past performance.

This repository is retained as a faithful reference of the original Le Wagon Rails project. A separate rebuild is intended outside this archive deployment.

## Live archive

- Render: https://form-calisthenics-app.onrender.com (Free, Ohio, Docker)
- Health check: `GET /up`
- Database: Neon Free PostgreSQL 16 (`form_calisthenics_app`)
- Media: existing Cloudinary Active Storage videos
- Migration PR: https://github.com/nkmatsumoto/form_calisthenics_app/pull/71

See [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md) for steady-state operations and [`docs/MIGRATION_REPORT.md`](docs/MIGRATION_REPORT.md) for migration evidence.

<img width="200" alt="Screenshot 2024-09-03 at 13 22 30" src="https://github.com/user-attachments/assets/746aa035-8260-4a86-8c6d-cb8685ffbc2a">
<img width="200" alt="Screenshot 2024-09-03 at 13 22 53" src="https://github.com/user-attachments/assets/1e522023-6b33-44bc-ad91-7a5bab946a5b">
<img width="200" alt="Screenshot 2024-09-03 at 13 24 32" src="https://github.com/user-attachments/assets/5d0c40ab-44ae-415b-b5c6-2ba100b3e240">
<img width="200" alt="Screenshot 2024-09-03 at 13 25 03" src="https://github.com/user-attachments/assets/b76c4791-a4b1-427b-b61b-d09f967fec50">

## Local setup

Requires Ruby 3.3.12 and PostgreSQL 16.

```bash
bundle install
```

Create `.env` (never commit it):

```bash
CLOUDINARY_URL=your_own_cloudinary_url_key
```

```bash
bin/rails db:prepare
bin/rails db:seed   # optional local sample data; not used for production restore
bin/rails server
```

Run migration regression tests:

```bash
bin/rails test
```

## Built with

- Rails 7.1
- Stimulus / Turbo
- PostgreSQL
- Cloudinary Active Storage
- Bootstrap
- Render + Neon (archive hosting)

## Team

- [Nicholas Matsumoto](https://www.linkedin.com/in/nicholas-matsumoto-18596a7b/)
- [Chaewan Shin](https://github.com/chaeshin)
- [Ryo Imakoa](https://github.com/rimaoka18)

## License

MIT
