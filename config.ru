require 'app'

use Rack::Static, :urls => ['/public']
run Kincurrent::App
