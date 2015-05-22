Rails.application.routes.draw do
  get  'users',         to: 'users#index'
  get  'user/:id',      to: 'users#show'
  post 'user/signup',   to: 'users#sign_up'
  post 'user/login',    to: 'users#log_in'
  get  'user/:id/following', to: 'users#following'
  get  'user/:id/followers', to: 'users#followers'
  get  'user/:id/feed',      to: 'users#feed'

  get  'post/:id',      to: 'posts#show'
  post 'post/create',   to: 'posts#create'
  patch 'post/:id/update', to: 'posts#update'
  get  'post/:id/likes', to: 'likes#post_likes'
  post 'post/:id/like', to: 'likes#create'

  get  'comment/:id', to: 'comments#show'
  post 'comment/create', to: 'comments#create'
  patch 'comment/:id/update', to: 'comments#update'
  get  'post/:id/comments', to: 'comments#post_comments'

end
