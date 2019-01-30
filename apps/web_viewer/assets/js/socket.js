import $ from "jquery"
import {Socket} from "phoenix"

export var socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()
