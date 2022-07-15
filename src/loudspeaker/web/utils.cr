macro layout(name)
  begin
    page = {{name}}
    render "src/loudspeaker/web/views/#{{{name}}}.html.ecr", "src/loudspeaker/web/views/layout.html.ecr"
  rescue e
    Logger.error(exception: e) { e.to_s }
    page = "Error"
    render "src/loudspeaker/web/views/message.html.ecr", "src/loudspeaker/web/views/layout.html.ecr"
  end
end

macro cors
  env.response.headers["Access-Control-Allow-Methods"] = "HEAD,GET,PUT,POST," \
  "DELETE,OPTIONS"
  env.response.headers["Access-Control-Allow-Headers"] = "X-Requested-With," \
    "X-HTTP-Method-Override, Content-Type, Cache-Control, Accept," \
    "Authorization"
  env.response.headers["Access-Control-Allow-Origin"] = "*"
end

def send_json(env, json)
  cors
  env.response.content_type = "application/json"
  env.response.print json
end

def send_text(env, text)
  cors
  env.response.content_type = "text/plain"
  env.response.print text
end

def send_attachment(env, path)
  cors
  send_file env, path, filename: File.basename(path), disposition: "attachment"
end
