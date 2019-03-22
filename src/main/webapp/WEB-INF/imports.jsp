<link href='webjars/bootstrap/4.2.1/css/bootstrap.min.css' rel='stylesheet' type='text/css'>
<script src='webjars/jquery/3.3.1-2/jquery.min.js'></script>
<script src='webjars/popper.js/1.14.6/umd/popper.min.js'></script>
<script src='webjars/bootstrap/4.2.1/js/bootstrap.min.js'></script>
<script>
  var bonuses;
  var bonusReadyHandlers = [];
  $(function () {
    $('[data-toggle="popover"]').popover();
    $('.popover-dismiss').popover({
      trigger: 'focus'
    });
  })
</script>
