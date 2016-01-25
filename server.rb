require "sinatra/base"
require "pg"
require "bcrypt"
require "pry"
require "redcarpet"

class Server < Sinatra::Base

	 enable :sessions

	 if ENV["RACK_ENV"] == "production"
    db = PG.connect(
    dbname: ENV["POSTGRES_DB"],
    host: ENV["POSTGRES_HOST"],
    password: ENV["POSTGRES_PASS"],
    user: ENV["POSTGRES_USER"] 
    )
  else
    db = PG.connect(dbname: "forum_project")
  end

      def current_user
        if session["user_id"]
          @users ||= db.exec_params(<<-SQL, [session["user_id"]]).first
            SELECT * FROM users WHERE id = $1
          SQL
        else
          # THE USER IS NOT LOGGED IN
          {}
        end
      end

	    get "/" do 
		    redirect "/signup"
	    end

	    get "/signup" do 
		    erb :signup
	    end

	  


      post "/signup" do
  	    encrypted_password = BCrypt::Password.create(params[:user_password])
        users = db.exec_params(<<-SQL, [params[:user_name], params[:user_email],encrypted_password]) 
        INSERT INTO users (user_name, user_email, user_password_digest) VALUES ($1, $2, $3) RETURNING id;
      SQL

        session["user_id"] = users.first["id"]
        # erb :topics
        redirect '/topics'
      end

	    get "/loggedin" do
	      erb :loggedin
	    end
	

      post "/loggedin" do
        @user = db.exec_params("SELECT * FROM users WHERE user_name = $1", [params[:user_name]]).first
        if @user
          if BCrypt::Password.new(@user["user_password_digest"]) == params[:user_password]	
            session["user_id"] = @user["id"]
            redirect "/signup"
          else
            @error = "Invalid Password"
            erb :loggedin
          end
        else
          @error = "Invalid Username"
          erb :loggedin
        end
      end


      get "/topics" do 
        if session["user_id"]
      	   db = PG.connect(dbname: "forum_project")
      	   @topics = db.exec("SELECT topic FROM topics").to_a
  	  	  erb :topics
        else
          "not logged in"
        end 
	   end


	   post "/topics" do
        user_id = session['user_id'].to_i
        topic = params['topic']
        db = PG.connect(dbname: "forum_project")
        new_topic = db.exec_params("INSERT INTO topics (user_id, topic) 
                                    VALUES ($1, $2) RETURNING id",[user_id,topic])   
        topic_submitted = true
	  	
        redirect "/topics/#{new_topic.first['id']}"
	   end

     get "/topics/:id" do 
        @posts = db.exec_params("SELECT posts.*, users.user_name FROM posts 
                                 LEFT JOIN users ON posts.user_id = users.id 
                                 WHERE topic_id = $1",[params[:id]])
        erb :posts
     end

    post "/posts" do 
      user_id = session['user_id'].to_i
      topic_id = params['topic_id']
      content = params['content']
      db = PG.connect(dbname: "forum_project")
      new_post = db.exec_params("INSERT INTO posts (user_id, topic_id, content) 
                        VALUES ($1, $2, $3) RETURNING id",[user_id, topic_id, content])
      
      # content_submitted = true
      redirect "/topics/#{topic_id}"
    end


     # get "/comments" do 
     #    @@db = PG.connect(dbname: "forum_project")
     #    @comments = @@db.exec("SELECT comment FROM comments").to_a
     #    erb :comments
     # end
     
     get "/comments" do
        @comments = db.exec_params("SELECT comments.*, users.user_name FROM comments 
                                  LEFT JOIN users ON comments.user_id = users.id
                                  WHERE post_id = $1",[params[:id]])
        erb :comments
     end

     post "/comments" do
        user_id = session['user_id'].to_i
        topic_id = params['topic_id']
        post_id = params ['post_id']
        comment = params['comment']
        count = params['count']    
      
        db = PG.connect(dbname: "forum_project")
        new_content = db.exec_params("INSERT INTO comments (user_id, topic_id, post_id, comment, count) 
                                    VALUES ($1, $2, $3, $4, $5) RETURNING id",[user_id, topic_id, post_id, comment, count])   
        content_submitted = true
      
        erb :comments
     end

    


   end



