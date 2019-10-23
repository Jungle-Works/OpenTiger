import { Component, PropTypes } from 'react';
import r, { a } from 'r-dom';
import classNames from 'classnames';
import { className } from '../../../utils/PropTypes';

import css from './Logo.css';

const logoContent = function logoContent(image, imageHighRes, text,flexTheme) {
  const higherRes = imageHighRes != null ? { srcSet: `${imageHighRes} 2x` } : null;

  if (image) {
    return r.img(Object.assign({}, {
      src: image,
      alt: text,
      className: css.logoImage,
      classSet: {[css.newlogoImage]: flexTheme||false}
    },
    higherRes));
  }
  return r.span({ className: css.logoText, classSet: {[css.newLogoText]: flexTheme||false} }, text);
};

class Logo extends Component {
  render() {
    return a({
      className: classNames('Logo', this.props.className, css.logo),
      href: this.props.href,
      style: this.props.color ? { color: this.props.color } : null,
      classSet: {[css.logoNewTheme]: this.props.flexTheme||false}
    }, [
        logoContent(this.props.image, this.props.image_highres, this.props.text,this.props.flexTheme),
        this.props.flexTheme ? r.span({className: classNames("logo-border", css.logoBorder)},"") : null
        ]);
  }
}

Logo.propTypes = {
  href: PropTypes.string.isRequired,
  image: PropTypes.string,
  image_highres: PropTypes.string,
  text: PropTypes.string.isRequired,
  color: PropTypes.string,
  className,
  flexTheme: PropTypes.bool
};

export default Logo;
