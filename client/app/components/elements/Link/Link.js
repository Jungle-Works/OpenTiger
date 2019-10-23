import { PropTypes } from 'react';
import { a,span } from 'r-dom';
import classNames from 'classnames';

import * as propTypeUtils from '../../../utils/PropTypes';
import * as variables from '../../../assets/styles/variables';

import css from './Link.css';

export default function Link({ href, className, customColor, openInNewTab, children,flexTheme }) {
  const color = customColor || variables['--customColorFallback'];

  return a({
    className: className || '',
    classSet: { [css.link]: true },
    href,
    style: { color },
    ...(openInNewTab ? { target: '_blank', rel: 'noreferrer' } : null),
  }, flexTheme ? [span({},children),span({className: classNames("logo-border", css.logoBorder)},"")] : children);
}

const { string, bool } = PropTypes;

Link.propTypes = {
  href: string.isRequired,
  className: propTypeUtils.className,
  customColor: string,
  openInNewTab: bool,
  children: string.isRequired,
  flexTheme: bool
};
