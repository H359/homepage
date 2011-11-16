$(document).ready(function(){
    $('ul.clients li a').each(function(num,a){
        a=$(a);
        a.addClass('bw');
        a.hover(function(e){ a.removeClass('bw');return false;});
        a.mouseout(function(e){ a.addClass('bw');return false;});
    });
});
