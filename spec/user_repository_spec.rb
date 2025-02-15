require 'bcrypt'
require 'user'
require 'user_repository'

def reset_peeps_users_tables
  seed_sql = File.read('schema/peeps_users_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'chitter_test' })
  connection.exec(seed_sql)
end

describe UserRepository do
  before do 
    reset_peeps_users_tables
    @repo = UserRepository.new
  end

  it 'gets all users' do
    users = @repo.all_users

    expect(users.length).to eq 4
    expect(users).to include(have_attributes(id: '1', email: 'samuelbadru@outlook.com', password: '$2a$12$GDZIoNTryOvWTakDIOeLaO5j3Z18GYz6NIwqi0WtkWX6SZkTN38a6', name: 'Samuel Badru', username: 'sobad'))
    expect(users).to include(have_attributes(id: '2', email: 'jermainecole@hotmail.com', password: '$2a$12$EbDxcnOtgHT5u1593.PLjuhv1Uv6r8QUFbLmqJbg2hol7e2n7dXCG', name: 'Jermaine Cole', username: 'j.cole'))
  end

  context "user sign in" do
      it 'uses the correct email and password' do
        user = @repo.sign_in('aubreygraham@gmail.com', 'hotlinebling')
        expect(user).to have_attributes(id: '3', email: 'aubreygraham@gmail.com', password: '$2a$12$OMGJGi6LFSxeD.cDwpJAE.MQqj6rhEDZs3DlB3fnfM31XXG8C58Ya', name: 'Aubrey Graham', username: 'drake')
      end

      it 'uses the incorrect username and password' do
        user = @repo.sign_in('kendricklamar', 'kidgood')
        expect(user).to eq false
      end
  end

  context 'create a user' do
    it 'uses an available username and email' do
      new_user = User.new
      new_user.email = 'santandave@icloud.com'
      new_user.password = 'psychodrama'
      new_user.name = 'Santan Dave'
      new_user.username = 'dave'

      expect(@repo.create_user(new_user)).to eq true
      users = @repo.all_users

      expect(users).to include(have_attributes(id: '5', email: 'santandave@icloud.com', name: 'Santan Dave', username: 'dave'))
    end

    it 'uses an unavailable username' do
      new_user = User.new
      new_user.email = 'drakebell@icloud.com'
      new_user.password = 'drakeandjosh'
      new_user.name = 'Drake Bell'
      new_user.username = 'drake'

      expect(@repo.create_user(new_user)).to eq false
    end

    it 'uses an unavailable email' do
      new_user = User.new
      new_user.email = 'samuelbadru@outlook.com'
      new_user.password = 'drakeandjosh'
      new_user.name = 'Drake Bell'
      new_user.username = 'drakejosh'

      expect(@repo.create_user(new_user)).to eq false
    end
  end
end