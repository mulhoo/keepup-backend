Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Development: Vite dev server
    origins "http://localhost:5173", "http://localhost:5174",
            # Demo deploy
            "https://keepup-demo.hajos.app",
            # Production web app (add when known)
            "https://keepup.hajos.app"

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: false,
      expose: ["Authorization"]
  end
end
