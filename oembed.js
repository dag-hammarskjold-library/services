if (!window.jQuery) {
	var jq = document.createElement('script'); jq.type = 'text/javascript';
	jq.src = 'https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js';
	document.getElementsByTagName('head')[0].appendChild(jq);
}

function showWidget(url) {
	// url here should be coming from the page that holds the embed button
	$.getJSON("http://localhost:9292/dsoembed?url=" + url, function( data ) {
		html_src = data["html"];
		$('#widget').append('<textarea cols="50" rows="4">' + html_src + '</textarea>');
		$('#widget').show();
	});
}