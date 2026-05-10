Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:5173", "http://localhost:5174",
            "https://keepup.hajos.app",
            "https://dev-keepup.hajos.app",
            "https://staging-keepup.hajos.app",
            /\Ahttps:\/\/[a-z0-9-]+\.keepup\.hajos\.app\z/

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: false,
      expose: ["Authorization"]
  end
end
