<?php

/**
 * Add extra links to the login page.
 *
 * @author     Einhard Leichtfuß
 * @copyright  2023, 2024 Einhard Leichtfuß
 * @license    https://www.gnu.org/licenses/agpl-3.0.html  AGPL 3.0 or later
 */

class login_page_extra_links extends rcube_plugin
{
  public $task = 'login';

  private $rc;
  private $extra_links_html;


  public function init()
  {
    $this->rc = rcube::get_instance();
    $this->load_config();

    $items = $this->rc->config->get('login_page_extra_links', []);

    $sep = $this->rc->config->get
      ( 'login_page_extra_links_separator'
      , ' &nbsp;&bull;&nbsp;&nbsp;'
      );

    $this->extra_links_html = '';
    foreach ($items as $item)
    {
      $this->extra_links_html .=
          $sep
        . '<a href="' . $item['url'] . '" target="_blank">'
        . $item['label']
        . '</a>';
    }

    $this->add_hook('template_container', [ $this, 'append_extra_links' ]);
  }


  public function append_extra_links($args)
  {
    if ($args['name'] == 'loginfooter')
    {
      return [ 'content' => $args['content'] . $this->extra_links_html ];
    }

    return null;
  }
}
