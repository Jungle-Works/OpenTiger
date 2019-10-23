import { PropTypes } from 'react';
import r, { div } from 'r-dom';
import { t } from '../../../utils/i18n';
import classNames from 'classnames';

import { className as classNameProp } from '../../../utils/PropTypes';
import Link from '../../elements/Link/Link';
import css from './LoginLinks.css';

export default function LoginLinks({ loginUrl, signupUrl, customColor, className,flexTheme }) {
  return div({
    className: classNames('LoginLinks', css.links, className),
    classSet: {[css.linksNewTheme]: flexTheme || false}
  }, [
    r(Link, {
      className: css.link,
      href: signupUrl,
      customColor,
      flexTheme: flexTheme
    }, t('web.topbar.signup')),
    r(Link, {
      className: css.link,
      href: loginUrl,
      customColor,
      flexTheme: flexTheme
    }, t('web.topbar.login')),
  ]);
}

LoginLinks.propTypes = {
  loginUrl: PropTypes.string.isRequired,
  signupUrl: PropTypes.string.isRequired,
  customColor: PropTypes.string,
  className: classNameProp,
  flexTheme: PropTypes.bool
};
